import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'add_address_screen.dart';
import 'outlet_selection_screen.dart';

class DeliveryAddressListScreen extends StatefulWidget {
  final bool isCheckoutMode;

  const DeliveryAddressListScreen({super.key, this.isCheckoutMode = false});

  @override
  State<DeliveryAddressListScreen> createState() =>
      _DeliveryAddressListScreenState();
}

class _DeliveryAddressListScreenState extends State<DeliveryAddressListScreen> {
  List<Map<String, dynamic>> addresses = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getStringList('saved_addresses');
    if (raw != null && raw.isNotEmpty) {
      try {
        setState(() {
          addresses = raw
              .map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList();
        });
      } catch (_) {}
    }

    if (addresses.isEmpty) {
      addresses = [
        {
          'label': 'Gedung FILKOM',
          'address': 'Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Malang',
          'latitude': -7.9553,
          'longitude': 112.6141,
        },
        {
          'label': 'Kost Dinoyo',
          'address': 'Jl. Sumbersari No. 45, Dinoyo, Malang',
          'latitude': -7.9580,
          'longitude': 112.6190,
        },
        {
          'label': 'Kost Zupen',
          'address': 'Jl. Soekarno Hatta No. 20, Malang',
          'latitude': -7.9670,
          'longitude': 112.6310,
        },
      ];
      await _saveAddresses();
      setState(() {});
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> addressesRaw = addresses
        .map((item) => jsonEncode(item))
        .toList();
    await prefs.setStringList('saved_addresses', addressesRaw);
  }

  Future<void> _selectAddress(int index) async {
    if (!widget.isCheckoutMode) return;

    setState(() {
      selectedIndex = index;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selected_delivery_address',
      jsonEncode(addresses[index]),
    );

    // Extract latitude and longitude from selected address
    final selectedAddress = addresses[index];
    final double? lat = selectedAddress['latitude'] as double?;
    final double? lon = selectedAddress['longitude'] as double?;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OutletSelectionScreen(userLat: lat, userLon: lon),
      ),
    );
  }

  Future<void> _editAddress(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          existingAddress: addresses[index],
          isEditing: true,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        addresses[index] = result;
      });
      await _saveAddresses();
    }
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressScreen()),
    );

    if (result != null) {
      setState(() {
        addresses.add(result);
      });
      await _saveAddresses();
    }
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
          widget.isCheckoutMode ? 'Pilih Alamat' : 'Alamat Pengiriman',
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
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(25),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: widget.isCheckoutMode
                              ? () => _selectAddress(index)
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: widget.isCheckoutMode && isSelected
                                  ? Border.all(color: primaryColor, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: lightYellowColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.home_outlined,
                                    color: primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address['label'] ?? 'Address',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        address['address'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!widget.isCheckoutMode)
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () => _editAddress(index),
                                  ),

                                if (widget.isCheckoutMode)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
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
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightYellowColor,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _addNewAddress,
                        child: Text(
                          'Tambah Alamat Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
