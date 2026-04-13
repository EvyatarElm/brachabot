import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/categories_data.dart';
import '../models/category_item.dart';
import '../widgets/category_card.dart';
import 'greeting_editor_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String shopId;

  const CategoriesScreen({super.key, required this.shopId});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _onCategoryPressed(CategoryItem category) async {
    final bool addImage = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'האם ברצונך להוסיף תמונה?',
              textDirection: TextDirection.rtl,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('לא'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('כן'),
              ),
            ],
          ),
        ) ??
        false;

    String? imagePath;

    if (addImage) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      imagePath = pickedFile.path;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GreetingEditorScreen(
          category: category,
          userImagePath: imagePath,
          shopId: widget.shopId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF3F342C),
          title: const Text(
            'בחירת קטגוריה',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1468327768560-75b778cbb551?auto=format&fit=crop&w=1400&q=80',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.88),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'בחר קטגוריה לברכה',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F2A26),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'לאחר הבחירה תוכל לעצב את הכרטיס, לבחור רקע, לכתוב את הברכה ולהוסיף תמונה.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Color(0xFF625B55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: GridView.builder(
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.02,
                      ),
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return CategoryCard(
                          category: category,
                          onTap: () => _onCategoryPressed(category),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}