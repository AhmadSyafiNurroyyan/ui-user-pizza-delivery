import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String name = '';
  String email = '';
  String mobile = '';
  String dob = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_profile');

    print('🔍 [DEBUG] Raw user_profile: $raw'); // Debug log

    if (raw != null) {
      try {
        final Map<String, dynamic> user = jsonDecode(raw);
        print('📦 [DEBUG] Parsed user data: $user'); // Debug log

        setState(() {
          name = user['nama'] ?? user['name'] ?? '';
          email = user['email'] ?? '';
          mobile = user['noHp'] ?? user['mobile'] ?? '';
          dob = user['dob'] ?? '';
        });

        print(
          '✅ [DEBUG] Loaded - Name: $name, Email: $email, Mobile: $mobile, DOB: $dob',
        ); // Debug log
      } catch (e) {
        print('❌ [DEBUG] Error parsing user_profile: $e'); // Debug log
      }
    } else {
      print(
        '⚠️ [DEBUG] No user_profile found in SharedPreferences',
      ); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 70, color: Colors.grey[600]),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Info banner jika data belum lengkap
            if (mobile.isEmpty || dob.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lengkapi profil Anda untuk pengalaman yang lebih baik.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            _profileField('Nama Lengkap', name),
            const SizedBox(height: 15),

            _profileField('Email', email),
            const SizedBox(height: 15),

            _profileField('Nomor Telepon', mobile.isEmpty ? '-' : mobile),
            const SizedBox(height: 15),

            _profileField('Tanggal Lahir', dob.isEmpty ? '-' : dob),
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  if (result == true) {
                    _loadUserProfile();
                  }
                },
                child: Text(
                  'Edit Profile',
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
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: value.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
