import 'dart:io';
import 'package:flutter/material.dart';
import '../models/category_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class GreetingEditorScreen extends StatefulWidget {
  final CategoryItem category;
  final String? userImagePath;
  final String shopId;

  const GreetingEditorScreen({
    super.key,
    required this.category,
    this.userImagePath,
    required this.shopId,
  });

  @override
  State<GreetingEditorScreen> createState() => _GreetingEditorScreenState();
}

class _GreetingEditorScreenState extends State<GreetingEditorScreen> {
  late String selectedBackground;
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _previewKey = GlobalKey();
  final double a5LandscapeRatio = 210 / 148;

Future<String?> _capturePreviewAsBase64() async {
  try {
    final boundary =
        _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;

    final pngBytes = byteData.buffer.asUint8List();
    return base64Encode(pngBytes);
  } catch (e) {
    debugPrint('Failed to capture preview: $e');
    return null;
  }
}

  Future<void> _sendPrintRequest() async {
  const serverUrl = 'https://brachabot.up.railway.app/print';

  try {
    await Future.delayed(const Duration(milliseconds: 50));
    final previewBase64 = await _capturePreviewAsBase64();

    if (previewBase64 == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('לא ניתן ליצור תמונת תצוגה מקדימה')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'previewImage': previewBase64,
        'shopId': widget.shopId,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('בקשת ההדפסה נשלחה')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בשליחה לשרת: ${response.statusCode}')),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('שגיאת חיבור לשרת: $e')),
    );
  }
}

  @override
  void initState() {
    super.initState();
    selectedBackground = widget.category.backgrounds.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get hasUserImage => widget.userImagePath != null;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('עיצוב ברכה - ${widget.category.title}'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildEditorSection()),
                      const SizedBox(width: 16),
                      SizedBox(width: 120, child: _buildBackgroundSelector()),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: _buildEditorSection()),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: _buildBackgroundSelector(isHorizontal: true),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorSection() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: a5LandscapeRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RepaintBoundary(
                    key: _previewKey,
                    child: AspectRatio(
                      aspectRatio: a5LandscapeRatio,
                      child: _buildCardPreview()),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: 5,
          textDirection: TextDirection.rtl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'הקלד כאן את הברכה...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB7885C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB7885C), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendPrintRequest,
            child: const Text('שלח להדפסה'),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        final leftRect = Rect.fromLTWH(
          cardWidth * 0.10 + 3,
          cardHeight * 0.17,
          cardWidth * 0.28,
          cardHeight * 0.62,
        );

        final rightRect = Rect.fromLTWH(
          cardWidth * 0.625,
          cardHeight * 0.20,
          cardWidth * 0.26,
          cardHeight * 0.44,
        );

        final String previewText = _textController.text.trim();

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(selectedBackground, fit: BoxFit.cover),
            ),

            if (hasUserImage)
              Positioned(
                left: leftRect.left,
                top: leftRect.top,
                width: leftRect.width,
                height: leftRect.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(widget.userImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text(
                          'לא ניתן לטעון תמונה',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Positioned(
              left: rightRect.left,
              top: rightRect.top,
              width: rightRect.width,
              height: rightRect.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: previewText.isEmpty
                    ? const SizedBox.shrink()
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: rightRect.width * 1.1,
                          child: Text(
                            previewText,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4038),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundSelector({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'רקעים',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isHorizontal
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.category.backgrounds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final bg = widget.category.backgrounds[index];
                    return _buildBackgroundThumbnail(bg);
                  },
                )
              : ListView.separated(
                  itemCount: widget.category.backgrounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bg = widget.category.backgrounds[index];
                    return _buildBackgroundThumbnail(bg);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBackgroundThumbnail(String bg) {
    final isSelected = bg == selectedBackground;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBackground = bg;
        });
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFB7885C) : Colors.transparent,
            width: 3,
          ),
          image: DecorationImage(image: AssetImage(bg), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
