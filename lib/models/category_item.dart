import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final List<String> backgrounds;

  const CategoryItem({
    required this.title,
    required this.icon,
    required this.backgrounds,
  });
}