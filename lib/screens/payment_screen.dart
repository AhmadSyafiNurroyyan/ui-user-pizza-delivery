import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/api_service.dart';
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
  bool isProcessing = false;
  int? selectedOutletId;
  String selectedPaymentMethod = 'CREDIT_CARD';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load selected outlet
    final outletIdStr = prefs.getString('selected_outlet_id');
    if (outletIdStr != null) {
      setState(() {
        selectedOutletId = int.tryParse(outletIdStr);
      });
    }

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

  Future<void> _handlePayment() async {
    // Validasi outlet sudah dipilih
    if (selectedOutletId == null) {
      _showError('Silakan pilih outlet terlebih dahulu');
      return;
    }

    // Validasi cart tidak kosong
    if (cartItems.isEmpty) {
      _showError('Keranjang masih kosong');
      return;
    }

    // Validasi alamat
    if (shippingAddress.isEmpty) {
      _showError('Silakan pilih alamat pengiriman');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Prepare order items untuk backend
      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        // Parse pizza ID dari item
        final pizzaId = item['id'] ?? 1;

        return {
          'pizzaId': pizzaId,
          'sizeId': 2, // Medium (default)
          'crustId': 2, // Regular (default)
          'quantity': item['quantity'] ?? 1,
          'toppingIds': [], // No toppings for now
        };
      }).toList();

      // Create order via API
      final response = await ApiService.createOrder(
        outletId: selectedOutletId!,
        alamatKirim: shippingAddress,
        items: orderItems,
        catatan: 'Order from mobile app',
      );

      if (response['success'] == true) {
        final data = response['data'];
        final orderId = data['data']['idPesanan'];

        // Update payment method
        final paymentResponse = await ApiService.updatePayment(
          orderId: orderId,
          paymentMethod: selectedPaymentMethod,
        );

        if (paymentResponse['success'] == true) {
          // Clear cart after successful order
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('cart_items');

          // Navigate to confirmation screen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConfirmOrderScreen()),
          );
        } else {
          _showError('Gagal memproses pembayaran');
        }
      } else {
        final errorMsg = response['data']['message'] ?? 'Gagal membuat pesanan';
        _showError(errorMsg);
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
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
                        onPressed: isProcessing ? null : _handlePayment,
                        child: isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
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
