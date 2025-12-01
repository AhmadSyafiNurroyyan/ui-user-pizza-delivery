import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'payment_screen.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;
  final bool isEditing;

  const AddAddressScreen({
    super.key,
    this.existingAddress,
    this.isEditing = false,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingAddress != null) {
      nameController.text = widget.existingAddress!['label'] ?? '';
      addressController.text = widget.existingAddress!['address'] ?? '';
    }
  }

  Future<void> _saveAddress() async {
    final name = nameController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon isi semua field')));
      return;
    }

    if (widget.isEditing) {
      final updatedAddress = {'label': name, 'address': address};
      Navigator.pop(context, updatedAddress);
      return;
    }

    if (widget.existingAddress == null) {
      final newAddress = {'label': name, 'address': address};
      Navigator.pop(context, newAddress);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> deliveryAddress = {
      'name': name,
      'address': address,
    };
    await prefs.setString('delivery_address', jsonEncode(deliveryAddress));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alamat berhasil disimpan!')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaymentScreen()),
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
          'Tambah Alamat Baru',
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.home_outlined, size: 100, color: primaryColor),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nama',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Royan House',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        filled: true,
                        fillColor: lightYellowColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Alamat',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '778 Locust View Drive\nOaklanda, CA',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        filled: true,
                        fillColor: lightYellowColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    SizedBox(
                      width: 200,
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
                        onPressed: _saveAddress,
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
