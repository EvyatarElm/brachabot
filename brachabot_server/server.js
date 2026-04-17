const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { PDFDocument } = require('pdf-lib');
const OpenAI = require('openai');

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const app = express();
const PORT = 3000;

app.use(express.json({ limit: '30mb' }));

// --- Job Queue ---
// Map<shopId, Array<Job>>
// Job: { jobId, shopId, status: 'pending'|'done'|'failed', createdAt, pdfPath, pngPath }
const jobQueue = new Map();

function getShopQueue(shopId) {
  if (!jobQueue.has(shopId)) {
    jobQueue.set(shopId, []);
  }
  return jobQueue.get(shopId);
}

// --- Jobs directory ---
const jobsDir = path.join(__dirname, 'jobs');
if (!fs.existsSync(jobsDir)) fs.mkdirSync(jobsDir);

// --- Agent secret middleware ---
const AGENT_SECRET = process.env.AGENT_SECRET || 'dev-secret';

function requireAgentSecret(req, res, next) {
  if (req.headers['x-agent-secret'] !== AGENT_SECRET) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

// --- Helper: mm to PDF points ---
function mmToPt(mm) {
  return (mm * 72) / 25.4;
}

// --- Helper: create printable PDF from image ---
async function createPrintableCardPdf(imagePath, outputPdfPath) {
  if (!fs.existsSync(imagePath)) {
    throw new Error('Preview image not found');
  }

  const imageBytes = fs.readFileSync(imagePath);
  const pdfDoc = await PDFDocument.create();

  const pageWidth = mmToPt(210);
  const pageHeight = mmToPt(148);

  const page = pdfDoc.addPage([pageWidth, pageHeight]);

  let embeddedImage;
  const lowerPath = imagePath.toLowerCase();

  if (lowerPath.endsWith('.png')) {
    embeddedImage = await pdfDoc.embedPng(imageBytes);
  } else if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
    embeddedImage = await pdfDoc.embedJpg(imageBytes);
  } else {
    throw new Error('Unsupported image format. Use PNG or JPG');
  }

  const imgWidth = embeddedImage.width;
  const imgHeight = embeddedImage.height;

  const pageRatio = pageWidth / pageHeight;
  const imgRatio = imgWidth / imgHeight;

  let drawWidth, drawHeight, drawX, drawY;

  if (imgRatio > pageRatio) {
    drawHeight = pageHeight;
    drawWidth = drawHeight * imgRatio;
    drawX = (pageWidth - drawWidth) / 2;
    drawY = 0;
  } else {
    drawWidth = pageWidth;
    drawHeight = drawWidth / imgRatio;
    drawX = 0;
    drawY = (pageHeight - drawHeight) / 2;
  }

  page.drawImage(embeddedImage, {
    x: drawX,
    y: drawY,
    width: drawWidth,
    height: drawHeight,
  });

  const pdfBytes = await pdfDoc.save();
  fs.writeFileSync(outputPdfPath, pdfBytes);
}

// -----------------------------------------------------------------------
// Routes
// -----------------------------------------------------------------------

app.get('/health', (req, res) => {
  res.send('Bracha Bot server is running');
});

// POST /print — client submits a card for printing
app.post('/print', async (req, res) => {
  try {
    const { previewImage, shopId } = req.body;

    if (!previewImage) {
      return res.status(400).json({ success: false, message: 'Missing previewImage' });
    }
    if (!shopId) {
      return res.status(400).json({ success: false, message: 'Missing shopId' });
    }

    const jobId = crypto.randomUUID();
    const pngPath = path.join(jobsDir, `${jobId}.png`);
    const pdfPath = path.join(jobsDir, `${jobId}.pdf`);

    // Save PNG
    const imageBuffer = Buffer.from(previewImage, 'base64');
    fs.writeFileSync(pngPath, imageBuffer);

    // Generate PDF
    await createPrintableCardPdf(pngPath, pdfPath);

    // Queue the job
    const job = {
      jobId,
      shopId,
      status: 'pending',
      createdAt: new Date().toISOString(),
      pdfPath,
      pngPath,
    };
    getShopQueue(shopId).push(job);

    console.log(`Job ${jobId} queued for shop: ${shopId}`);

    return res.json({
      success: true,
      jobId,
      message: 'Print job queued',
    });
  } catch (error) {
    console.error('Server error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create printable card',
      error: error.message,
    });
  }
});

// GET /jobs/:shopId — agent polls for pending jobs
app.get('/jobs/:shopId', requireAgentSecret, (req, res) => {
  const { shopId } = req.params;
  const queue = getShopQueue(shopId);
  const pendingJobs = queue
    .filter((j) => j.status === 'pending')
    .map(({ jobId, status, createdAt }) => ({ jobId, status, createdAt }));

  return res.json({ shopId, jobs: pendingJobs });
});

// GET /jobs/:shopId/:jobId/pdf — agent downloads the PDF for a job
app.get('/jobs/:shopId/:jobId/pdf', requireAgentSecret, (req, res) => {
  const { shopId, jobId } = req.params;
  const queue = getShopQueue(shopId);
  const job = queue.find((j) => j.jobId === jobId && j.shopId === shopId);

  if (!job) {
    return res.status(404).json({ error: 'Job not found' });
  }
  if (!fs.existsSync(job.pdfPath)) {
    return res.status(404).json({ error: 'PDF file not found on server' });
  }

  return res.download(job.pdfPath, `${jobId}.pdf`);
});

// POST /jobs/:shopId/:jobId/status — agent marks job done or failed
app.post('/jobs/:shopId/:jobId/status', requireAgentSecret, (req, res) => {
  const { shopId, jobId } = req.params;
  const { status, error: errorMsg } = req.body;

  if (!['done', 'failed'].includes(status)) {
    return res.status(400).json({ error: 'status must be "done" or "failed"' });
  }

  const queue = getShopQueue(shopId);
  const job = queue.find((j) => j.jobId === jobId && j.shopId === shopId);

  if (!job) {
    return res.status(404).json({ error: 'Job not found' });
  }

  job.status = status;
  if (errorMsg) job.error = errorMsg;

  // Clean up files on success
  if (status === 'done') {
    try {
      if (fs.existsSync(job.pdfPath)) fs.unlinkSync(job.pdfPath);
      if (fs.existsSync(job.pngPath)) fs.unlinkSync(job.pngPath);
    } catch (e) {
      console.warn(`Could not delete files for job ${jobId}:`, e.message);
    }
  }

  console.log(`Job ${jobId} marked as ${status} for shop: ${shopId}`);
  return res.json({ success: true });
});

// POST /generate-greeting — AI greeting generation via OpenAI
app.post('/generate-greeting', async (req, res) => {
  try {
    const { recipient, name, ageRange, occasion, style } = req.body;

    if (!recipient || !name || !occasion || !style) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const prompt = `כתוב ברכה קצרה (שניים או שלושה משפטים), אישית, טבעית ונעימה בעברית, שמתאימה להדפסה על כרטיס ברכה קטן.

פרטי ההקשר:
- למי מיועדת הברכה: ${recipient}
- שם הנמען/ת: ${name}
- טווח גילאים: ${ageRange}
- סוג המאורע: ${occasion}
- אופי הברכה: ${style}

הנחיות:
- הברכה צריכה להיות קצרה ומתאימה לכרטיס פיזי קטן.
- יש לשמור על עברית תקינה, זורמת וטבעית.
- יש להתאים את הניסוח לגיל, למאורע, ולקהל היעד.
- יש להתאים את הטון לסגנון המבוקש.
- אין לכתוב ברכה גנרית מדי או רשמית מדי, אלא אם זה נדרש לפי הסגנון.
- אין להוסיף כותרות, הסברים, מרכאות או טקסט נוסף.
- החזר רק את נוסח הברכה עצמה.

אם רלוונטי, שלב את שם הנמען/ת בצורה טבעית בתוך הברכה.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 200,
    });

    const greeting = completion.choices[0].message.content.trim();
    console.log(`Generated greeting for ${name} (${recipient}, ${occasion})`);

    return res.json({ greeting });
  } catch (error) {
    console.error('Error generating greeting:', error);
    return res.status(500).json({ error: 'Failed to generate greeting' });
  }
});

// Serve Flutter web build (run `flutter build web` first)
app.use(express.static(path.join(__dirname, '../build/web')));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
