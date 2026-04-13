import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';

void main() {
  String shopId = 'unknown_shop';
  if (kIsWeb) {
    shopId = Uri.base.queryParameters['shop'] ?? 'unknown_shop';
  }
  runApp(BrachaBotApp(shopId: shopId));
}

class BrachaBotApp extends StatelessWidget {
  final String shopId;

  const BrachaBotApp({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bracha Bot',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F5F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB7885C),
          brightness: Brightness.light,
        ),
      ),
      home: HomeScreen(shopId: shopId),
    );
  }
}
