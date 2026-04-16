import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/greeting_options_data.dart';
import '../models/greeting_answers.dart';

class AiGreetingScreen extends StatefulWidget {
  const AiGreetingScreen({super.key});

  @override
  State<AiGreetingScreen> createState() => _AiGreetingScreenState();
}

class _AiGreetingScreenState extends State<AiGreetingScreen> {
  int _step = 0;

  // Collected answers
  RecipientOption? _recipient;
  final TextEditingController _nameController = TextEditingController();
  String? _ageRange;
  String? _occasion;

  bool _isLoading = false;
  String? _errorMessage;

  static const _brandColor = Color(0xFFB7885C);
  static const _textDark = Color(0xFF2F2A26);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> get _occasions =>
      _recipient != null ? (occasionsByRecipient[_recipient!.id] ?? []) : [];

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _recipient != null;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 2:
        return _ageRange != null;
      case 3:
        return _occasion != null;
      default:
        return false;
    }
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _generate();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final answers = GreetingAnswers(
      recipientId: _recipient!.id,
      recipientLabel: _recipient!.label,
      name: _nameController.text.trim(),
      ageRange: _ageRange!,
      occasion: _occasion!,
    );

    try {
      const url = 'https://brachabot-production.up.railway.app/generate-greeting';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipient': answers.recipientLabel,
          'name': answers.name,
          'ageRange': answers.ageRange,
          'occasion': answers.occasion,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final greeting = data['greeting'] as String;
        Navigator.of(context).pop(greeting);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'שגיאה מהשרת (${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'שגיאת חיבור לשרת';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5F1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _textDark,
          centerTitle: true,
          title: const Text(
            'הגרלת ברכה',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: _step > 0 && !_isLoading
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _back,
                )
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Progress indicator
                if (!_isLoading)
                  _buildProgress(),
                const SizedBox(height: 24),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading
                        ? _buildLoading()
                        : _buildStepContent(),
                  ),
                ),

                // Next button
                if (!_isLoading)
                  _buildNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: List.generate(4, (i) {
        final isActive = i <= _step;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive ? _brandColor : const Color(0xFFDDD0C4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildRecipientStep();
      case 1:
        return _buildNameStep();
      case 2:
        return _buildAgeStep();
      case 3:
        return _buildOccasionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRecipientStep() {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion('למי הברכה?'),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: recipients.map((r) {
              final isSelected = _recipient?.id == r.id;
              return _buildOptionTile(
                label: r.label,
                isSelected: isSelected,
                onTap: () => setState(() => _recipient = r),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion('מה שמו/שמה?'),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'הקלד שם...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brandColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brandColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeStep() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion('מה טווח הגיל?'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ageRanges.map((age) {
            return _buildOptionTile(
              label: age,
              isSelected: _ageRange == age,
              onTap: () => setState(() => _ageRange = age),
              width: 100,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOccasionStep() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion('מה האירוע?'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _occasions.map((occ) {
            return _buildOptionTile(
              label: occ,
              isSelected: _occasion == occ,
              onTap: () => setState(() => _occasion = occ),
              width: 130,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _brandColor),
          const SizedBox(height: 24),
          const Text(
            'מייצר ברכה מושלמת...',
            style: TextStyle(fontSize: 18, color: _textDark),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(backgroundColor: _brandColor),
              child: const Text('נסה שוב'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestion(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: _textDark,
      ),
    );
  }

  Widget _buildOptionTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _brandColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _brandColor : const Color(0xFFDDD0C4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = _step == 3;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _canAdvance ? _next : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          disabledBackgroundColor: const Color(0xFFD9C4B0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isLast ? 'צור ברכה' : 'הבא',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
