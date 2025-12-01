import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.restaurant,
        'title': 'Kami menambahkan\nproduk yang\nmungkin kamu suka',
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Salah satu produk\nfavoritmu sedang\ndalam promosi',
      },
      {'icon': Icons.shopping_bag, 'title': 'Pesananmu telah\ndiproses'},
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Pengiriman sedang\ndalam perjalanan',
      },
      {'icon': Icons.shopping_bag, 'title': 'Pesananmu telah\ndikirim'},
    ];

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [

                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 30),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white24, height: 50),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          notification['icon'],
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
