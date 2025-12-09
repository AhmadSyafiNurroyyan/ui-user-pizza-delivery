import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  String selectedSize = 'Medium';
  int selectedSizeId = 2; // ID dari database
  String selectedCrust = 'Regular';
  int selectedCrustId = 2; // ID dari database
  List<String> selectedToppings = [];
  List<int> selectedToppingIds = [];
  String specialInstructions = '';

  // Data sizes yang MATCH 100% dengan database
  final List<Map<String, dynamic>> sizes = [
    {'id': 1, 'name': 'Small', 'price': 0, 'multiplier': 1.0},
    {'id': 2, 'name': 'Medium', 'price': 0, 'multiplier': 1.5},
    {'id': 3, 'name': 'Large', 'price': 0, 'multiplier': 2.0},
    {'id': 4, 'name': 'Extra Large', 'price': 0, 'multiplier': 2.5},
  ];

  // Data crusts yang MATCH 100% dengan database
  final List<Map<String, dynamic>> crusts = [
    {'id': 1, 'name': 'Thin Crust', 'price': 0},
    {'id': 2, 'name': 'Regular', 'price': 5000},
    {'id': 3, 'name': 'Thick Crust', 'price': 10000},
    {'id': 4, 'name': 'Stuffed Crust', 'price': 15000},
    {'id': 5, 'name': 'Cheese Burst', 'price': 20000},
  ];

  // Data toppings yang MATCH 100% dengan database
  final List<Map<String, dynamic>> toppings = [
    {'id': 1, 'name': 'Extra Cheese', 'price': 10000},
    {'id': 2, 'name': 'Pepperoni', 'price': 15000},
    {'id': 3, 'name': 'Mushroom', 'price': 8000},
    {'id': 4, 'name': 'Black Olives', 'price': 8000},
    {'id': 5, 'name': 'Green Peppers', 'price': 7000},
    {'id': 6, 'name': 'Onions', 'price': 5000},
    {'id': 7, 'name': 'Italian Sausage', 'price': 15000},
    {'id': 8, 'name': 'Bacon', 'price': 15000},
    {'id': 9, 'name': 'Pineapple', 'price': 10000},
    {'id': 10, 'name': 'Jalapeños', 'price': 8000},
  ];

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  int _calculateTotalPrice() {
    // Parse base price dari widget
    final basePrice =
        widget.item['priceNum'] ??
        int.parse(
          widget.item['price']
              .toString()
              .replaceAll('Rp', '')
              .replaceAll(' ', '')
              .replaceAll('.', ''),
        );

    // Size menggunakan multiplier (sesuai database)
    final sizeData = sizes.firstWhere((s) => s['name'] == selectedSize);
    final sizeMultiplier = sizeData['multiplier'] as double;
    final sizeAdjustedPrice = (basePrice * sizeMultiplier).toInt();

    // Crust additional price
    final crustPrice =
        crusts.firstWhere((c) => c['name'] == selectedCrust)['price'] as int;

    // Toppings total price
    int toppingsPrice = 0;
    for (var topping in selectedToppings) {
      toppingsPrice +=
          toppings.firstWhere((t) => t['name'] == topping)['price'] as int;
    }

    return sizeAdjustedPrice + crustPrice + toppingsPrice;
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesRaw =
        prefs.getStringList('favorite_items') ?? [];
    final favorites = favoritesRaw
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    setState(() {
      isFavorite = favorites.any((item) => item['name'] == widget.item['name']);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesRaw = prefs.getStringList('favorite_items') ?? [];
    List<Map<String, dynamic>> favorites = favoritesRaw
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    if (isFavorite) {
      favorites.removeWhere((item) => item['name'] == widget.item['name']);
      setState(() {
        isFavorite = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dihapus dari favorit', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      final favoriteItem = {
        'name': widget.item['name'],
        'price': widget.item['price'],
        'image': widget.item['img'],
        'description': 'Pizza lezat dengan bahan berkualitas premium',
      };
      favorites.add(favoriteItem);
      setState(() {
        isFavorite = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ditambahkan ke favorit!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    favoritesRaw = favorites.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('favorite_items', favoritesRaw);
  }

  Future<void> _addToCart(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart_items');

    List<Map<String, dynamic>> cartItems = [];
    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        cartItems = decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    final customizedItem = {
      'id': widget.item['id'], // Pizza ID dari database
      'name': widget.item['name'],
      'price': _formatPrice(_calculateTotalPrice()),
      'img': widget.item['img'],
      'quantity': 1,
      'customization': {
        'size': selectedSize,
        'sizeId': selectedSizeId,
        'crust': selectedCrust,
        'crustId': selectedCrustId,
        'toppings': selectedToppings,
        'toppingIds': selectedToppingIds,
        'specialInstructions': specialInstructions,
      },
    };

    final existingIndex = cartItems.indexWhere(
      (cartItem) =>
          cartItem['name'] == widget.item['name'] &&
          cartItem['customization']?['size'] == selectedSize &&
          cartItem['customization']?['crust'] == selectedCrust &&
          (cartItem['customization']?['toppings'] as List?)
                  ?.toSet()
                  .containsAll(selectedToppings.toSet()) ==
              true &&
          selectedToppings.toSet().containsAll(
            (cartItem['customization']?['toppings'] as List?)?.toSet() ?? {},
          ),
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] =
          (cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      cartItems.add(customizedItem);
    }

    await prefs.setString('cart_items', jsonEncode(cartItems));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditambahkan ke keranjang!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 110,
              backgroundImage: NetworkImage(widget.item['img']),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item['name'], style: titleStyle),
                      const SizedBox(height: 10),
                      Text(
                        _formatPrice(_calculateTotalPrice()),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Deskripsi dummy: Makanan ini dibuat dengan bahan pilihan terbaik. Cocok untuk dinikmati saat mengerjakan tugas deadline.",
                        style: subTitleStyle,
                      ),
                      const SizedBox(height: 25),

                      _buildCustomizationSection(),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: () => _addToCart(context),
                          child: Text(
                            "Tambah ke Keranjang - ${_formatPrice(_calculateTotalPrice())}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        'Rating dan ulasan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rating dan ulasan dari pelanggan yang telah memesan pizza ini',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '4,1',
                                    style: GoogleFonts.poppins(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < 4
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '234',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),

                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildRatingBar(5, 0.85),
                                  const SizedBox(height: 6),
                                  _buildRatingBar(4, 0.10),
                                  const SizedBox(height: 6),
                                  _buildRatingBar(3, 0.03),
                                  const SizedBox(height: 6),
                                  _buildRatingBar(2, 0.01),
                                  const SizedBox(height: 6),
                                  _buildRatingBar(1, 0.01),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildReviewItem(
                        'Annida Puteri kamella',
                        5,
                        '22/11/25',
                        'Pizzanya enak banget! Toppingnya melimpah, kejunya meleleh sempurna. Dari dulu pesan di sini selalu puas, rasa dan kualitasnya konsisten terus.',
                      ),
                      const SizedBox(height: 2),
                      _buildReviewItem(
                        'Ervin Maulana',
                        5,
                        '22/11/25',
                        'Suka banget dengan pizza ini! Crustnya crispy di luar tapi lembut di dalam. Porsinya pas, harganya juga reasonable. Delivery cepat dan ramah.',
                      ),
                      const SizedBox(height: 2),
                      _buildReviewItem(
                        'Budi Santoso',
                        5,
                        '20/11/25',
                        'Enak banget! Pizzanya fresh, keju meleleh sempurna, dan toppingnya banyak. Recommended banget deh pokoknya! Pengiriman juga cepat, masih hangat sampai rumah.',
                      ),
                      const SizedBox(height: 2),
                      _buildReviewItem(
                        'Siti Rahayu',
                        4,
                        '18/11/25',
                        'Rasanya enak, harganya juga terjangkau. Cuma sayang kemarin sampenya agak lama. Tapi overall worth it sih, bakal order lagi!',
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text(
          stars.toString(),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(
    String userName,
    int rating,
    String time,
    String comment,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Text(
                  userName[0],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey[600], size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[800],
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kustomisasi Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),

        _buildSizeSelector(),
        const SizedBox(height: 20),

        _buildCrustSelector(),
        const SizedBox(height: 20),

        _buildToppingsSelector(),
        const SizedBox(height: 20),

        _buildSpecialInstructions(),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ukuran',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: sizes.map((size) {
            final isSelected = selectedSize == size['name'];
            return ChoiceChip(
              label: Text(
                '${size['name']} ${size['price'] > 0 ? '(+${_formatPrice(size['price'])})' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedSize = size['name'];
                  selectedSizeId = size['id'];
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.grey[200],
              elevation: isSelected ? 2 : 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCrustSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Crust',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: crusts.map((crust) {
            final isSelected = selectedCrust == crust['name'];
            return ChoiceChip(
              label: Text(
                '${crust['name']} ${crust['price'] > 0 ? '(+${_formatPrice(crust['price'])})' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCrust = crust['name'];
                  selectedCrustId = crust['id'];
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.grey[200],
              elevation: isSelected ? 2 : 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToppingsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topping Tambahan',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: toppings.map((topping) {
            final isSelected = selectedToppings.contains(topping['name']);
            return FilterChip(
              label: Text(
                '${topping['name']} (+${_formatPrice(topping['price'])})',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedToppings.add(topping['name']);
                    selectedToppingIds.add(topping['id']);
                  } else {
                    selectedToppings.remove(topping['name']);
                    selectedToppingIds.remove(topping['id']);
                  }
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.grey[200],
              checkmarkColor: Colors.white,
              elevation: isSelected ? 2 : 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan Khusus',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) {
            setState(() {
              specialInstructions = value;
            });
          },
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Contoh: Jangan terlalu pedas, extra saus...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }
}
