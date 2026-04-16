const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

// -----------------------------------------------------------------------
// Configuration — set these as environment variables on the local PC
// -----------------------------------------------------------------------
const CLOUD_SERVER_URL = process.env.CLOUD_SERVER_URL || 'https://brachabot-production.up.railway.app';
const SHOP_ID = 'yotam_flowers'; // e.g. 'yotam_flowers' — REQUIRED
const AGENT_SECRET = 'super_secret_key_of_yotam_flower_shop';
const POLL_INTERVAL_MS = parseInt(process.env.POLL_INTERVAL_MS || '5000', 10);
const PRINTER_NAME = process.env.PRINTER_NAME || 'HP126DCB (HP Smart Tank 750 series)';
const SUMATRA_PATH =
  process.env.SUMATRA_PATH ||
  'C:\\Program Files\\SumatraPDF\\SumatraPDF.exe';

// -----------------------------------------------------------------------
// Validation
// -----------------------------------------------------------------------
if (!SHOP_ID) {
  console.error('ERROR: SHOP_ID environment variable is required.');
  console.error('Example: SHOP_ID=yotam_flowers node agent.js');
  process.exit(1);
}

const JOBS_DIR = path.join(__dirname, 'downloaded_jobs');
if (!fs.existsSync(JOBS_DIR)) fs.mkdirSync(JOBS_DIR);

const agentHeaders = { 'x-agent-secret': AGENT_SECRET };

// Tracks jobs currently being processed to prevent duplicate processing
const processingJobs = new Set();

// -----------------------------------------------------------------------
// Polling loop
// -----------------------------------------------------------------------
async function poll() {
  try {
    const response = await fetch(`${CLOUD_SERVER_URL}/jobs/${SHOP_ID}`, {
      headers: agentHeaders,
    });

    if (!response.ok) {
      console.error(`Poll failed: HTTP ${response.status}`);
      return;
    }

    const data = await response.json();
    const pendingJobs = data.jobs;

    if (pendingJobs.length > 0) {
      console.log(`[${new Date().toISOString()}] Found ${pendingJobs.length} pending job(s)`);
    }

    for (const job of pendingJobs) {
      if (processingJobs.has(job.jobId)) continue;
      processingJobs.add(job.jobId);
      processJob(job.jobId).finally(() => processingJobs.delete(job.jobId));
    }
  } catch (err) {
    console.error('Network error during poll:', err.message);
  }
}

// -----------------------------------------------------------------------
// Process a single job
// -----------------------------------------------------------------------
async function processJob(jobId) {
  console.log(`Processing job: ${jobId}`);
  const pdfPath = path.join(JOBS_DIR, `${jobId}.pdf`);

  try {
    // Step 1: Download PDF
    const pdfResponse = await fetch(
      `${CLOUD_SERVER_URL}/jobs/${SHOP_ID}/${jobId}/pdf`,
      { headers: agentHeaders }
    );

    if (!pdfResponse.ok) {
      throw new Error(`PDF download failed: HTTP ${pdfResponse.status}`);
    }

    const pdfBuffer = await pdfResponse.buffer();
    fs.writeFileSync(pdfPath, pdfBuffer);
    console.log(`PDF saved: ${pdfPath}`);

    // Step 2: Send to printer
    printPdf(pdfPath);
    console.log(`Print command issued for job: ${jobId}`);

    // Step 3: Mark done on server
    await markJobStatus(jobId, 'done');

    // Step 4: Clean up local file
    fs.unlinkSync(pdfPath);
    console.log(`Job ${jobId} complete.`);
  } catch (err) {
    console.error(`Failed to process job ${jobId}:`, err.message);
    await markJobStatus(jobId, 'failed', err.message);
    // Keep the local PDF for manual inspection if it was saved
  }
}

// -----------------------------------------------------------------------
// Cross-platform printing
// -----------------------------------------------------------------------
function printPdf(pdfPath) {
  const platform = os.platform();

  if (platform === 'win32') {
    const sumatraCandidates = [
      SUMATRA_PATH,
      `C:\\Users\\${os.userInfo().username}\\AppData\\Local\\SumatraPDF\\SumatraPDF.exe`,
      'C:\\Program Files\\SumatraPDF\\SumatraPDF.exe',
      'C:\\Program Files (x86)\\SumatraPDF\\SumatraPDF.exe',
    ];

    const sumatraExe = sumatraCandidates.find(p => fs.existsSync(p));

    if (!sumatraExe) {
      throw new Error(
        'SumatraPDF not found. Please install it from https://www.sumatrapdfreader.org'
      );
    }

    const printerArg = PRINTER_NAME ? `-print-to "${PRINTER_NAME}"` : '-print-to-default';
    execSync(`"${sumatraExe}" -exit-when-done ${printerArg} "${pdfPath}"`);

  } else if (platform === 'linux' || platform === 'darwin') {
    const printerArg = PRINTER_NAME ? `-d "${PRINTER_NAME}"` : '';
    execSync(`lp ${printerArg} "${pdfPath}"`);
  } else {
    throw new Error(`Unsupported platform: ${platform}`);
  }
}

// -----------------------------------------------------------------------
// Mark job status on the server
// -----------------------------------------------------------------------
async function markJobStatus(jobId, status, errorMsg) {
  try {
    await fetch(`${CLOUD_SERVER_URL}/jobs/${SHOP_ID}/${jobId}/status`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...agentHeaders,
      },
      body: JSON.stringify({ status, error: errorMsg }),
    });
  } catch (err) {
    console.error(`Failed to update status for job ${jobId}:`, err.message);
  }
}

// -----------------------------------------------------------------------
// Start
// -----------------------------------------------------------------------
console.log(`BrachaBOT agent started`);
console.log(`  Shop ID:    ${SHOP_ID}`);
console.log(`  Server URL: ${CLOUD_SERVER_URL}`);
console.log(`  Poll every: ${POLL_INTERVAL_MS}ms`);
console.log(`  Printer:    ${PRINTER_NAME || '(default)'}`);
console.log('');

poll(); // run immediately on startup
setInterval(poll, POLL_INTERVAL_MS);
