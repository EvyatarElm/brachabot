import 'package:flutter/material.dart';
import '../models/category_item.dart';

const List<CategoryItem> categories = [
  CategoryItem(
    title: 'לאישה',
    icon: Icons.favorite_outline,
    backgrounds: [
      'assets/backgrounds/wife/wife1.png',
      'assets/backgrounds/wife/wife2.png',
      'assets/backgrounds/wife/wife3.png',
    ],
  ),
  CategoryItem(
    title: 'ליום הולדת',
    icon: Icons.cake_outlined,
    backgrounds: [
      'assets/backgrounds/birthday/birthday1.png',
      'assets/backgrounds/birthday/birthday2.png',
      'assets/backgrounds/birthday/birthday3.png',
    ],
  ),
  CategoryItem(
    title: 'לבן / בת הזוג',
    icon: Icons.favorite_border,
    backgrounds: [
      'assets/backgrounds/couple_1.jpg',
      'assets/backgrounds/couple_2.jpg',
    ],
  ),
];