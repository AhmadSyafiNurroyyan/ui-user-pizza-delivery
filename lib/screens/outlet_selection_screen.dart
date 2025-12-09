import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../models/outlet.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class OutletSelectionScreen extends StatefulWidget {
  final double? userLat;
  final double? userLon;

  const OutletSelectionScreen({super.key, this.userLat, this.userLon});

  @override
  State<OutletSelectionScreen> createState() => _OutletSelectionScreenState();
}

class _OutletSelectionScreenState extends State<OutletSelectionScreen> {
  List<Outlet> outlets = [];
  Outlet? selectedOutlet;
  bool isLoading = true;
  bool showAllOutlets = false;

  // Fallback dummy outlets (match database structure)
  final List<Outlet> _dummyOutlets = [
    Outlet(
      id: 1,
      outletCode: 'PZ-DNY01',
      nama: 'Pizza Hut Dinoyo',
      alamat: 'Jl. MT. Haryono No. 165, Dinoyo, Malang',
      latitude: -7.956567,
      longitude: 112.617829,
      telepon: '0341-12345678',
      jamOperasional: '10:00 - 22:00',
    ),
    Outlet(
      id: 2,
      outletCode: 'PZ-SHT02',
      nama: 'Pizza Hut Soekarno Hatta',
      alamat: 'Jl. Soekarno Hatta No. 1A, Malang',
      latitude: -7.966620,
      longitude: 112.632632,
      telepon: '0341-23456789',
      jamOperasional: '10:00 - 22:00',
    ),
    Outlet(
      id: 3,
      outletCode: 'PZ-VET03',
      nama: 'Pizza Hut Veteran',
      alamat: 'Jl. Veteran No. 23, Malang',
      latitude: -7.952479,
      longitude: 112.614647,
      telepon: '0341-34567890',
      jamOperasional: '10:00 - 22:00',
    ),
    Outlet(
      id: 4,
      outletCode: 'PZ-DNG04',
      nama: 'Pizza Hut Dieng',
      alamat: 'Jl. Raya Dieng No. 50, Malang',
      latitude: -7.938889,
      longitude: 112.616667,
      telepon: '0341-45678901',
      jamOperasional: '10:00 - 22:00',
    ),
    Outlet(
      id: 5,
      outletCode: 'PZ-TLG05',
      nama: 'Pizza Hut Tlogomas',
      alamat: 'Jl. Tlogomas No. 45, Malang',
      latitude: -7.930000,
      longitude: 112.600000,
      telepon: '0341-56789012',
      jamOperasional: '10:00 - 22:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOutletTerdekat();
  }

  Future<void> _loadOutletTerdekat() async {
    setState(() => isLoading = true);

    try {
      // Fetch outlets from backend API
      final response = await ApiService.getOutlets();

      if (response['success'] == true) {
        final data = response['data'];
        final List<dynamic> outletList = data['data'] ?? [];

        // Get user location from widget parameter or default
        double userLat = widget.userLat ?? -7.9553; // Default FILKOM UB
        double userLon = widget.userLon ?? 112.6141;

        // Parse outlets from API and calculate distance
        outlets = outletList.map((item) {
          final outlet = Outlet.fromJson(item);
          double jarak = _hitungJarakHaversine(
            userLat,
            userLon,
            outlet.latitude,
            outlet.longitude,
          );
          return outlet.copyWith(jarak: jarak);
        }).toList();

        // Sort by nearest distance
        outlets.sort((a, b) => a.jarak.compareTo(b.jarak));

        // Select nearest outlet by default
        if (outlets.isNotEmpty) {
          selectedOutlet = outlets.first;
        }
      } else {
        // Fallback to dummy data if API fails
        print('⚠️ Failed to fetch outlets from API, using fallback data');
        _useFallbackOutlets();
      }
    } catch (e) {
      // Fallback to dummy data on error
      print('❌ Error fetching outlets: $e');
      _useFallbackOutlets();
    }

    setState(() => isLoading = false);
  }

  void _useFallbackOutlets() {
    // Get user location
    double userLat = widget.userLat ?? -7.9553;
    double userLon = widget.userLon ?? 112.6141;

    // Use dummy data as fallback
    outlets = _dummyOutlets.map((outlet) {
      double jarak = _hitungJarakHaversine(
        userLat,
        userLon,
        outlet.latitude,
        outlet.longitude,
      );
      return outlet.copyWith(jarak: jarak);
    }).toList();

    outlets.sort((a, b) => a.jarak.compareTo(b.jarak));
    if (outlets.isNotEmpty) {
      selectedOutlet = outlets.first;
    }
  }

  Future<void> _saveSelectedOutlet() async {
    if (selectedOutlet == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selected_outlet',
      jsonEncode({
        'id': selectedOutlet!.id,
        'nama': selectedOutlet!.nama,
        'alamat': selectedOutlet!.alamat,
      }),
    );

    // Save outlet ID for backend API (convert int to String)
    await prefs.setString('selected_outlet_id', selectedOutlet!.id.toString());

    setState(() => isLoading = false);
  }

  // Haversine formula to calculate distance between two coordinates
  double _hitungJarakHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  String _formatJarak(double jarak) {
    if (jarak < 1) {
      return '${(jarak * 1000).toStringAsFixed(0)} m';
    }
    return '${jarak.toStringAsFixed(1)} km';
  }

  Future<void> _selectOutlet(Outlet outlet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selected_outlet',
      jsonEncode({
        'id': outlet.id,
        'nama': outlet.nama,
        'alamat': outlet.alamat,
      }),
    );

    // Save outlet ID for backend API (convert int to String)
    await prefs.setString('selected_outlet_id', outlet.id.toString());

    setState(() {
      selectedOutlet = outlet;
    });
  }

  void _lanjutKePayment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Outlet',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : showAllOutlets
          ? _buildAllOutletsList()
          : _buildNearestOutletView(),
    );
  }

  // Initial view: nearest outlet only
  Widget _buildNearestOutletView() {
    if (selectedOutlet == null) return const SizedBox();

    return Column(
      children: [
        // Success header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kami telah menemukan outlet terdekat dari lokasi Kamu!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Store icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store, size: 80, color: primaryColor),
                ),
                const SizedBox(height: 24),

                // Nearest badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Outlet Terdekat',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Outlet card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedOutlet!.nama,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        selectedOutlet!.alamat,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.directions_car,
                        '${_formatJarak(selectedOutlet!.jarak)} dari lokasi Kamu',
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'Buka: ${selectedOutlet!.jamOperasional}',
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.phone,
                        selectedOutlet!.telepon,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Delivery estimate info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estimasi waktu pengiriman dari outlet ini sekitar 20-30 menit',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Pakai Outlet Ini" button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _lanjutKePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pakai Outlet Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // "Ganti Outlet" button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showAllOutlets = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ganti Outlet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  // Complete list view with all outlets sorted by distance
  Widget _buildAllOutletsList() {
    return Column(
      children: [
        // Info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pilih outlet yang Kamu inginkan. Outlet diurutkan berdasarkan jarak terdekat.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Outlets list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: outlets.length,
            itemBuilder: (context, index) {
              final outlet = outlets[index];
              final isSelected = selectedOutlet?.id == outlet.id;
              final isNearest = index == 0;

              return GestureDetector(
                onTap: () => _selectOutlet(outlet),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Store icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Outlet info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        outlet.nama,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isNearest)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Terdekat',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        outlet.alamat,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 12),

                      // Additional info chips
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.directions_car,
                            _formatJarak(outlet.jarak),
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.access_time,
                            outlet.jamOperasional,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            outlet.telepon,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected outlet info
                if (selectedOutlet != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Outlet Terpilih',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                selectedOutlet!.nama,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedOutlet != null ? _lanjutKePayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Lanjut ke Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
