import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int selectedRating = 4;
  double priceValue = 30;
  Set<String> selectedCategories = {'Cupcakes', 'Chocolate'};

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.cookie_outlined, 'label': 'Snacks'},
    {'icon': Icons.restaurant_outlined, 'label': 'Meal'},
    {'icon': Icons.eco_outlined, 'label': 'Vegan'},
    {'icon': Icons.cake_outlined, 'label': 'Dessert'},
    {'icon': Icons.local_drink_outlined, 'label': 'Drinks'},
  ];

  final List<String> categoryChips = [
    'Crepes',
    'Macarons',
    'Cupcakes',
    'Ice Cream',
    'Flan',
    'Cheesecake',
    'Chocolate',
    'Cakes',
    'Brownie',
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
        title: Text(
          'Filter',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Kategori',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: categories.map((cat) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: lightYellowColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                cat['icon'],
                                color: primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['label'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Urutkan berdasarkan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Top Rated',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ...List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: primaryColor,
                              size: 22,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categoryChips.map((chip) {
                        final isSelected = selectedCategories.contains(chip);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedCategories.remove(chip);
                              } else {
                                selectedCategories.add(chip);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : lightYellowColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              chip,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : primaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Price',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: priceValue,
                        min: 1,
                        max: 100,
                        onChanged: (value) {
                          setState(() {
                            priceValue = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp 10.000',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Rp 30.000',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Rp 50.000',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Rp 100.000 >',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
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
