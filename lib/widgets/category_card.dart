import 'package:flutter/material.dart';
import '../models/category_item.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE9DDD2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 30, color: const Color(0xFFB7885C)),
              const SizedBox(height: 12),
              Text(
                category.title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}