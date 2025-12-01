import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> promotions = [
      {
        'name': 'Pizza Margherita',
        'description':
            'Rasakan keautentikan Italia dengan Pizza Margherita. Terdiri dari crust yang renyah dan lembut, dilapisi saus tomat spesial, lelehan keju mozzarella, serta sentuhan akhir dari minyak zaitun dan daun basil segar. Kesederhanaan yang menciptakan ledakan rasa',
        'price': 'Rp 85.000',
        'originalPrice': null,
        'discount': null,
        'rating': 4.8,
        'image':
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=400&auto=format&fit=crop',
      },
      {
        'name': 'Pizza Pepperoni Cheese',
        'description':
            'Pizza klasik yang tak pernah gagal! Pepperoni premium dengan keju mozzarella berlimpah di atas saus tomat pilihan. Setiap gigitan memberikan kombinasi gurih dan sedikit pedas yang sempurna',
        'price': 'Rp 98.000',
        'originalPrice': 'Rp 140.000',
        'discount': '-30%',
        'rating': 5.0,
        'image':
            'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=400&auto=format&fit=crop',
      },
      {
        'name': 'Pizza BBQ Chicken',
        'description':
            'Ayam panggang dengan saus BBQ spesial, bawang bombay, paprika, dan keju cheddar yang melimpah. Rasa manis dan gurih yang sempurna dalam setiap gigitan',
        'price': 'Rp 95.000',
        'originalPrice': 'Rp 125.000',
        'discount': '-24%',
        'rating': 4.7,
        'image':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=400&auto=format&fit=crop',
      },
      {
        'name': 'Pizza Supreme',
        'description':
            'Kombinasi lengkap dengan pepperoni, sosis Italia, paprika hijau, bawang bombay, jamur, dan zaitun hitam. Untuk pecinta topping berlimpah!',
        'price': 'Rp 115.000',
        'originalPrice': null,
        'discount': null,
        'rating': 4.9,
        'image':
            'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?q=80&w=400&auto=format&fit=crop',
      },
      {
        'name': 'Pizza Hawaiian',
        'description':
            'Perpaduan unik antara ham asap dan nanas tropis dengan keju mozzarella. Kombinasi manis dan asin yang kontroversial tapi disukai banyak orang',
        'price': 'Rp 92.000',
        'originalPrice': 'Rp 110.000',
        'discount': '-16%',
        'rating': 4.5,
        'image':
            'https://images.unsplash.com/photo-1565299507177-b0ac66763828?q=80&w=400&auto=format&fit=crop',
      },
    ];

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
          'Mungkin Kamu Suka',
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
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                    child: Text(
                      'Rekomendasi Special Untukmu',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: promotions.length,
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return GestureDetector(
                          onTap: () {

                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: Image.network(
                                        promo['image'],
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: 180,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 50,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    if (promo['discount'] != null)
                                      Positioned(
                                        top: 15,
                                        right: 15,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            promo['discount'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              promo['name'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                promo['rating'].toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        promo['description'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            promo['price'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          if (promo['originalPrice'] !=
                                              null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              promo['originalPrice'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
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
