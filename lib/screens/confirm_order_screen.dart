import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'order_confirmation_screen.dart';
import 'order_cancelled_screen.dart';

class ConfirmOrderScreen extends StatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
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

  void _updateQuantity(int index, int delta) {
    setState(() {
      cartItems[index]['quantity'] = (cartItems[index]['quantity'] + delta)
          .clamp(1, 99);
      _calculateTotals();
    });
    _saveCart();
  }

  void _removeItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Order',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        cartItems.removeAt(index);
        _calculateTotals();
      });
      _saveCart();

      if (!mounted) return;
      if (cartItems.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderCancelledScreen()),
        );
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_items', jsonEncode(cartItems));
  }

  Future<void> _placeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm Order',
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
                          'Shipping Address',
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
                          'Order Summary',
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
                    const SizedBox(height: 20),
                    ...cartItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final quantity = item['quantity'] ?? 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightYellowColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['img'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '29 Nov, 15:20 pm',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryColor,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => _removeItem(index),
                                      child: Text(
                                        'Cancel Order',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: primaryColor,
                                  ),
                                  onPressed: () => _removeItem(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['price'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$quantity items',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      color: primaryColor,
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, size: 14),
                                        color: Colors.white,
                                        onPressed: () =>
                                            _updateQuantity(index, 1),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    _summaryRow('Subtotal', 'Rp ${subtotal.toInt()}'),
                    const SizedBox(height: 12),
                    _summaryRow('Tax and Fees', 'Rp ${tax.toInt()}'),
                    const SizedBox(height: 12),
                    _summaryRow('Delivery', 'Rp ${delivery.toInt()}'),
                    const Divider(height: 30),
                    _summaryRow('Total', 'Rp ${total.toInt()}', isTotal: true),
                    const SizedBox(height: 40),
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
                        onPressed: _placeOrder,
                        child: Text(
                          'Pesan Sekarang',
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

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _navIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }
}
