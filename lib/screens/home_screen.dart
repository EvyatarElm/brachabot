import 'package:flutter/material.dart';
import 'categories_screen.dart';

class HomeScreen extends StatelessWidget {
  final String shopId;

  const HomeScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=1400&q=80',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.75),
                  Colors.white.withOpacity(0.90),
                ],
              ),
            ),
          ),
           SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BARACHA BOT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5D4A3A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ברכה מושלמת לכל רגע',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F2A26),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'יוצרים כרטיס ברכה מעוצב בכמה צעדים פשוטים',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF5E5853),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoriesScreen(shopId: shopId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB7885C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'התחל ברכה',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                 ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}