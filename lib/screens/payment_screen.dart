import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'confirm_order_screen.dart';
import 'delivery_address_list_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String shippingAddress = '778 Locust View Drive Oaklanda, CA';
  List<Map<String, dynamic>> cartItems = [];
  double subtotal = 0;
  double tax = 0;
  double delivery = 15000;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final selectedAddressRaw = prefs.getString('selected_delivery_address');
    if (selectedAddressRaw != null) {
      try {
        final Map<String, dynamic> selectedAddr = jsonDecode(
          selectedAddressRaw,
        );
        setState(() {
          shippingAddress = selectedAddr['address'] ?? shippingAddress;
        });
      } catch (_) {}
    }

    final addressRaw = prefs.getString('delivery_address');
    if (addressRaw != null) {
      try {
        final Map<String, dynamic> address = jsonDecode(addressRaw);
        setState(() {
          shippingAddress = address['address'] ?? shippingAddress;
        });
      } catch (_) {}
    }

    final cartRaw = prefs.getString('cart_items');
    if (cartRaw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartRaw);
        setState(() {
          cartItems = decoded.cast<Map<String, dynamic>>();
          _calculateTotals();
        });
      } catch (_) {}
    }
  }

  void _calculateTotals() {
    double sub = 0;
    for (var item in cartItems) {
      final priceStr = item['price'].toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final price = double.tryParse(priceStr) ?? 0;
      final quantity = item['quantity'] ?? 1;
      sub += price * quantity;
    }
    setState(() {
      subtotal = sub;
      tax = sub * 0.1;
      total = subtotal + tax + delivery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: yellowColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const DeliveryAddressListScreen(isCheckoutMode: true),
              ),
            );
          },
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Text(
                          'Alamat Pengiriman',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 18, color: primaryColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: lightYellowColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        shippingAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ringkasan Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lightYellowColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Edit',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    ...cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              '${item['quantity']} items',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rp ${total.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lightYellowColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Edit',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card, color: primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              'Credit Card',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lightYellowColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '··· ··· ··· 43 /00 /000',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    Text(
                      'Delivery Time',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '25 mins',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightYellowColor,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConfirmOrderScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Bayar Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navIcon(Icons.home_outlined),
                _navIcon(Icons.restaurant_menu_outlined),
                _navIcon(Icons.favorite_border),
                _navIcon(Icons.receipt_long_outlined),
                _navIcon(Icons.headset_mic_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }
}
