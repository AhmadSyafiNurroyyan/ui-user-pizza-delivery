import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ContactUsScreen extends StatefulWidget {
  final int initialTab;
  const ContactUsScreen({super.key, this.initialTab = 1});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late int _selectedTab;
  int? expandedFAQIndex;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  final List<Map<String, String>> faqs = [
    {
      'question': 'Bagaimana cara memesan pizza?',
      'answer':
          'Kamu dapat memesan pizza melalui aplikasi ini dengan memilih menu yang diinginkan, menambahkan ke keranjang, lalu melakukan checkout dengan memilih alamat pengiriman dan metode pembayaran.',
    },
    {
      'question': 'Berapa lama waktu pengiriman?',
      'answer':
          'Waktu pengiriman estimasi adalah 25-45 menit tergantung lokasi Kamu. Kamu dapat melacak status pesanan secara real-time melalui fitur Track Order.',
    },
    {
      'question': 'Apakah ada biaya pengiriman?',
      'answer':
          'Ya, biaya pengiriman sebesar Rp 15.000 untuk setiap pesanan. Biaya ini sudah termasuk dalam total pembayaran Kamu.',
    },
    {
      'question': 'Bagaimana cara membatalkan pesanan?',
      'answer':
          'Kamu dapat membatalkan pesanan melalui menu My Orders pada tab Active. Pilih pesanan yang ingin dibatalkan dan pilih alasan pembatalan.',
    },
    {
      'question': 'Metode pembayaran apa saja yang tersedia?',
      'answer':
          'Kami menerima berbagai metode pembayaran termasuk kartu kredit/debit, e-wallet (GoPay, OVO, Dana), dan transfer bank.',
    },
    {
      'question': 'Apakah bisa pesan untuk acara besar?',
      'answer':
          'Tentu! Untuk pesanan dalam jumlah besar atau catering, silakan hubungi customer service kami melalui WhatsApp atau telepon untuk mendapatkan penawaran khusus.',
    },
  ];

  final List<Map<String, dynamic>> contactMethods = [
    {
      'icon': Icons.headset_mic_outlined,
      'title': 'Customer Service',
      'subtitle': '021-1234-5678',
      'expandable': false,
    },
    {
      'icon': Icons.language,
      'title': 'Website',
      'subtitle': 'www.pizzadelivery.com',
      'expandable': false,
    },
    {
      'icon': Icons.phone_outlined,
      'title': 'WhatsApp',
      'subtitle': '+62 812-3456-7890',
      'expandable': false,
    },
    {
      'icon': Icons.facebook_outlined,
      'title': 'Facebook',
      'subtitle': '@pizzadeliveryid',
      'expandable': false,
    },
    {
      'icon': Icons.camera_alt_outlined,
      'title': 'Instagram',
      'subtitle': '@pizzadeliveryid',
      'expandable': false,
    },
  ];

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
        title: Column(
          children: [
            Text(
              _selectedTab == 0 ? 'Pusat Bantuan' : 'Hubungi Kami',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Gimana Kami Bisa Bantu?',
              style: GoogleFonts.poppins(fontSize: 13, color: primaryColor),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton('FAQ', 0)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTabButton('Hubungi Kami', 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Expanded(
                    child: _selectedTab == 0
                        ? _buildFAQContent()
                        : _buildContactContent(),
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightYellowColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }

  Widget _buildFAQContent() {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCategoryButton('General', true),
              const SizedBox(width: 10),
              _buildCategoryButton('Account', false),
              const SizedBox(width: 10),
              _buildCategoryButton('Services', false),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
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
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primaryColor,
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              final isExpanded = expandedFAQIndex == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedFAQIndex = expanded ? index : null;
                      });
                    },
                    title: Text(
                      faq['question']!,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? primaryColor : Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: primaryColor,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: contactMethods.length,
      itemBuilder: (context, index) {
        final method = contactMethods[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(method['icon'], color: primaryColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (method['subtitle'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        method['subtitle'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: primaryColor,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : lightYellowColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : primaryColor,
          ),
        ),
      ),
    );
  }
}
