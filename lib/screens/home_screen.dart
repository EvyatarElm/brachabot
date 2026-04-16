import 'package:flutter/material.dart';
import '../data/shops_data.dart';
import '../models/shop_item.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  final String initialShopId;

  const HomeScreen({super.key, required this.initialShopId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ShopItem? _selectedShop;

  @override
  void initState() {
    super.initState();
    // Pre-select shop if one was provided via URL (?shop=) or dart-define
    if (widget.initialShopId.isNotEmpty && widget.initialShopId != 'unknown_shop') {
      _selectedShop = shops.where((s) => s.id == widget.initialShopId).firstOrNull;
    }
  }

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
                          'BRACHA BOT',
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
                        const SizedBox(height: 24),

                        // Shop dropdown
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFB7885C)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ShopItem>(
                                value: _selectedShop,
                                isExpanded: true,
                                hint: const Text(
                                  'בחר חנות להדפסה',
                                  style: TextStyle(color: Color(0xFF9E8C7E)),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Color(0xFFB7885C)),
                                items: shops.map((shop) {
                                  return DropdownMenuItem<ShopItem>(
                                    value: shop,
                                    child: Text(shop.displayName),
                                  );
                                }).toList(),
                                onChanged: (ShopItem? value) {
                                  setState(() => _selectedShop = value);
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Start button — disabled until a shop is selected
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _selectedShop == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CategoriesScreen(
                                          shopId: _selectedShop!.id,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB7885C),
                              disabledBackgroundColor: const Color(0xFFD9C4B0),
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
