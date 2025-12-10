import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/api_service.dart';
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
  double outletDistance = 0.0; // Jarak outlet dalam km
  double total = 0;
  bool isProcessing = false;
  int? selectedOutletId;
  String? selectedOutletName;
  String selectedPaymentMethod = 'BANK_TRANSFER';
  String selectedPaymentLabel = 'Transfer Bank';
  IconData selectedPaymentIcon = Icons.account_balance;

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

    final selectedOutletRaw = prefs.getString('selected_outlet');
    if (selectedOutletRaw != null) {
      try {
        final Map<String, dynamic> outletData = jsonDecode(selectedOutletRaw);
        setState(() {
          selectedOutletName = outletData['nama'];
          // Load jarak outlet (dalam km)
          outletDistance = (outletData['jarak'] ?? 2.0) as double;
          // Calculate dynamic delivery fee
          _calculateDeliveryFee();
        });
      } catch (_) {}
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

  // Calculate delivery fee based on outlet distance
  void _calculateDeliveryFee() {
    // Formula: Rp 5.000/km dengan minimum Rp 10.000 dan maksimum Rp 30.000
    const double pricePerKm = 5000;
    const double minimumFee = 10000;
    const double maximumFee = 30000;

    double calculatedFee = outletDistance * pricePerKm;

    // Apply minimum and maximum limits
    if (calculatedFee < minimumFee) {
      calculatedFee = minimumFee;
    } else if (calculatedFee > maximumFee) {
      calculatedFee = maximumFee;
    }

    setState(() {
      delivery = calculatedFee;
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
        final pizzaId = item['id'] ?? 1;
        final customization = item['customization'] ?? {};
        final sizeId = customization['sizeId'] ?? 2;
        final crustId = customization['crustId'] ?? 2;
        final toppingIds = List<int>.from(customization['toppingIds'] ?? []);
        final quantity = item['quantity'] ?? 1;

        return {
          'pizzaId': pizzaId,
          'sizeId': sizeId,
          'crustId': crustId,
          'quantity': quantity,
          'toppingIds': toppingIds,
          'specialInstructions': customization['specialInstructions'] ?? '',
        };
      }).toList();

      // Create order via API
      final response = await ApiService.createOrder(
        outletId: selectedOutletId!,
        alamatKirim: shippingAddress,
        items: orderItems,
        catatan: 'Order from mobile app',
        metodeBayar: selectedPaymentMethod,
      );

      if (response['success'] == true) {
        // Clear cart after successful order
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cart_items');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderConfirmationScreen(),
          ),
        );
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

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pilih Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentOption(
                  label: 'Transfer Bank',
                  subtitle: 'BCA, BNI, Mandiri, BRI',
                  icon: Icons.account_balance,
                  paymentMethod: 'BANK_TRANSFER',
                  paymentLabel: 'Transfer Bank',
                ),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  label: 'GoPay',
                  subtitle: 'Bayar dengan GoPay',
                  icon: Icons.account_balance_wallet,
                  paymentMethod: 'E_WALLET',
                  paymentLabel: 'GoPay',
                ),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  label: 'DANA',
                  subtitle: 'Bayar dengan DANA',
                  icon: Icons.account_balance_wallet,
                  paymentMethod: 'E_WALLET',
                  paymentLabel: 'DANA',
                ),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  label: 'Bayar di Tempat (COD)',
                  subtitle: 'Bayar saat pesanan tiba',
                  icon: Icons.money,
                  paymentMethod: 'CASH',
                  paymentLabel: 'Bayar di Tempat (COD)',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String paymentMethod,
    required String paymentLabel,
  }) {
    final isSelected =
        selectedPaymentMethod == paymentMethod &&
        selectedPaymentLabel == paymentLabel;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = paymentMethod;
          selectedPaymentLabel = paymentLabel;
          selectedPaymentIcon = icon;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? lightYellowColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: primaryColor),
          ],
        ),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Konfirmasi Pesanan',
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
                    // 1. Hapus icon pensil di sebelah Alamat Pengiriman
                    Text(
                      'Alamat Pengiriman',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    // 2. Fungsikan icon "Edit" agar kembali ke keranjang
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
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: lightYellowColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 14, color: primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                                  const SizedBox(height: 8),
                                  Text(
                                    item['price'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Customization info (jika ada)
                                  if (item['customization'] != null) ...[
                                    Text(
                                      'Size: ${item['customization']['sizeName'] ?? 'Medium'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Crust: ${item['customization']['crustName'] ?? 'Regular'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Tombol quantity control
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    // Tombol Minus
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                        color: primaryColor,
                                        onPressed: () =>
                                            _updateQuantity(index, -1),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Tombol Plus
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, size: 16),
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
                    _summaryRow('Pajak', 'Rp ${tax.toInt()}'),
                    const SizedBox(height: 12),
                    _summaryRow('Ongkir', 'Rp ${delivery.toInt()}'),
                    const Divider(height: 30),
                    _summaryRow('Total', 'Rp ${total.toInt()}', isTotal: true),
                    const SizedBox(height: 30),

                    // Payment Method Section
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showPaymentMethodDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightYellowColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedPaymentIcon,
                              color: primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPaymentLabel,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    selectedPaymentMethod == 'CASH'
                                        ? 'Bayar saat pesanan tiba'
                                        : 'Bayar sekarang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: primaryColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Outlet Info
                    if (selectedOutletName != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.store, color: Colors.blue, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pesanan dari: $selectedOutletName',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isProcessing
                              ? Colors.grey
                              : lightYellowColor,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isProcessing ? null : _placeOrder,
                        child: isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Memproses...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
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
