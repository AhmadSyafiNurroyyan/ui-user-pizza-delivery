import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'detail_screen.dart';
import 'notifications_screen.dart';
import 'contact_us_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'filter_screen.dart';
import 'my_orders_screen.dart';
import 'promotions_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> bestSeller = [
      {
        "name": "Pepperoni Pizza",
        "price": "Rp 97.000",
        "img":
            "https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=300&auto=format&fit=crop",
      },
      {
        "name": "Cheese Pizza",
        "price": "Rp 81.000",
        "img":
            "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop",
      },
      {
        "name": "Veggie Pizza",
        "price": "Rp 91.000",
        "img":
            "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=300&auto=format&fit=crop",
      },
      {
        "name": "BBQ Pizza",
        "price": "Rp 78.000",
        "img":
            "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=300&auto=format&fit=crop",
      },
    ];

    final List<Map<String, dynamic>> recommend = [
      {
        "name": "Marinara Pizza",
        "price": "Rp 105.000",
        "rating": "5.0",
        "img":
            "https://images.unsplash.com/photo-1595854341625-f33ee10dbf94?q=80&w=300&auto=format&fit=crop",
      },
      {
        "name": "Hawaiian Pizza",
        "price": "Rp 89.000",
        "rating": "4.9",
        "img":
            "https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?q=80&w=300&auto=format&fit=crop",
      },
    ];

    return Scaffold(
      backgroundColor: yellowColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showSearch(
                                  context: context,
                                  delegate: _SearchDelegate(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Cari',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _iconButton(Icons.shopping_cart_outlined, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          _iconButton(Icons.notifications_outlined, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          _iconButton(Icons.person_outline, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Selamat Pagi',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Mulai Hari Dengan Rasa',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _categoryIcon(Icons.cookie_outlined, 'Snacks'),
                              _categoryIcon(Icons.restaurant_outlined, 'Meal'),
                              _categoryIcon(Icons.eco_outlined, 'Vegan'),
                              _categoryIcon(Icons.cake_outlined, 'Dessert'),
                              _categoryIcon(
                                Icons.local_drink_outlined,
                                'Drinks',
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terlaris',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FilterScreen(),
                                    ),
                                  );
                                },
                                tooltip: 'Filter',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bestSeller.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                          item: bestSeller[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 15),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: Image.network(
                                            bestSeller[index]['img'],
                                            width: 110,
                                            height: 130,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              bestSeller[index]['price'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
                          const SizedBox(height: 25),

                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [primaryColor, Color(0xFFD84A35)],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 20,
                                    top: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.45,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rasakan menu',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            'lezat terbaru kami',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '30% OFF',
                                              style: GoogleFonts.poppins(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: yellowColor,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        child: Image.network(
                                          'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=400&auto=format&fit=crop',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Text(
                            'Rekomendasi',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: recommend.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreen(item: item),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: index == 0 ? 10 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: Image.network(
                                            item['img'],
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  item['rating'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                const Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.amber,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item['price'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {

                      },
                      child: _navIcon(Icons.home, true),
                    ),
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PromotionsScreen(),
                          ),
                        );
                      },
                      child: _navIcon(Icons.restaurant_menu_outlined, false),
                    ),
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                      child: _navIcon(Icons.favorite_border, false),
                    ),
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      child: _navIcon(Icons.receipt_long_outlined, false),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ),
                        );
                      },
                      child: _navIcon(Icons.headset_mic_outlined, false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: lightYellowColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: primaryColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(icon, color: Colors.white, size: isActive ? 30 : 26);
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Cari pizza...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: yellowColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.poppins(color: Colors.white70),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          'Hasil pencarian untuk: $query',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        [
              'Pepperoni Pizza',
              'Cheese Pizza',
              'Veggie Pizza',
              'BBQ Pizza',
              'Marinara Pizza',
              'Hawaiian Pizza',
            ]
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.search, color: primaryColor),
            title: Text(suggestions[index], style: GoogleFonts.poppins()),
            onTap: () {
              query = suggestions[index];
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
