import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'order_cancelled_screen.dart';

class CancelOrderScreen extends StatefulWidget {
  final String orderName;
  final String orderPrice;

  const CancelOrderScreen({
    super.key,
    required this.orderName,
    required this.orderPrice,
  });

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();

  final List<String> cancelReasons = [
    'Saya ingin mengubah alamat pengiriman',
    'Saya ingin mengubah pesanan saya',
    'Saya memesan secara tidak sengaja',
    'Waktu pengiriman terlalu lama',
    'Saya menemukan harga yang lebih baik di tempat lain',
  ];

  @override
  void dispose() {
    otherReasonController.dispose();
    super.dispose();
  }

  void _submitCancellation() {
    if (selectedReason == null && otherReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon pilih alasan pembatalan atau isi alasan lainnya.',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OrderCancelledScreen()),
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
          'Cancel Order',
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lightYellowColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Please select the reason for cancelling this order. This will help us improve our service.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...cancelReasons.map((reason) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedReason == reason
                                    ? primaryColor
                                    : Colors.grey[300]!,
                                width: selectedReason == reason ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedReason == reason
                                          ? primaryColor
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: selectedReason == reason
                                        ? primaryColor
                                        : Colors.transparent,
                                  ),
                                  child: selectedReason == reason
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Text(
                      'Lainnya',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: lightYellowColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: otherReasonController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Alasan lainnya...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              selectedReason = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _submitCancellation,
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
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
