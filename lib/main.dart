import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';

void main() {
  // 1. Check for a compile-time override (used when running on Android/iOS for testing)
  //    e.g. flutter run --dart-define=SHOP_ID=yotam_flowers
  const String dartDefineShopId = String.fromEnvironment('SHOP_ID');

  String shopId;
  if (dartDefineShopId.isNotEmpty) {
    shopId = dartDefineShopId;
  } else if (kIsWeb) {
    // 2. On web, read from the URL query param set by the QR code
    shopId = Uri.base.queryParameters['shop'] ?? 'unknown_shop';
  } else {
    shopId = 'unknown_shop';
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
      home: HomeScreen(initialShopId: shopId),
    );
  }
}
