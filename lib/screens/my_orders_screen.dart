import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'leave_review_screen.dart';
import 'view_review_screen.dart';
import 'cancel_order_screen.dart';
import 'delivery_time_screen.dart';
import 'cart_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int _selectedTab = 0; // 0: Active, 1: Completed, 2: Cancelled
  List<Map<String, dynamic>> activeOrders = [];
  List<Map<String, dynamic>> completedOrders = [];
  List<Map<String, dynamic>> cancelledOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getMyOrders();

      print('📦 My Orders Response: $response');

      if (response['success'] == true || response['status'] == 'sukses') {
        // ApiService wraps backend response: {success: true, data: {status: "sukses", data: [...]}}
        // Extract the actual data array
        var dataWrapper = response['data'];
        final List<dynamic> orders = (dataWrapper is List)
            ? dataWrapper
            : (dataWrapper['data'] ?? []);

        print('✅ Found ${orders.length} orders');

        List<Map<String, dynamic>> active = [];
        List<Map<String, dynamic>> completed = [];
        List<Map<String, dynamic>> cancelled = [];

        for (var order in orders) {
          print(
            '🔍 Processing order: ${order['idPesanan']} - Status: ${order['statusPesanan']}',
          );

          final orderData = {
            'id': order['idPesanan'],
            'orderNumber': order['orderNumber'] ?? 'ORD-${order['idPesanan']}',
            'name': (order['items'] != null && order['items'].isNotEmpty)
                ? (order['items'][0]['menuName'] ?? 'Pizza Order')
                : 'Pizza Order',
            'date': _formatDate(
              order['tanggalPemesanan'] ?? order['tanggalPesan'],
            ),
            'price': 'Rp ${_formatPrice(order['totalHarga'])}',
            'status': order['statusPesanan'] ?? 'PENDING',
            'items': '${order['items']?.length ?? 0} items',
            'img': (order['items'] != null && order['items'].isNotEmpty)
                ? (order['items'][0]['imageUrl'] ??
                      'https://images.unsplash.com/photo-1513104890138-7c749659a591')
                : 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
            'canReview': order['opsiUlasan'] == true,
            'fullItems': order['items'] ?? [], // Simpan data items lengkap
            // Review data
            'hasReview': order['ulasan'] != null,
            'reviewRating': order['ulasan']?['rating'],
            'reviewComment': order['ulasan']?['komentar'] ?? '',
            'reviewDate': order['ulasan']?['tanggalUlasan'],
          };

          // Categorize by status
          if (order['statusPesanan'] == 'SELESAI') {
            completed.add(orderData);
          } else if (order['statusPesanan'] == 'DIBATALKAN') {
            cancelled.add(orderData);
          } else {
            active.add(orderData);
          }
        }

        print(
          '📊 Active: ${active.length}, Completed: ${completed.length}, Cancelled: ${cancelled.length}',
        );

        print(
          '📊 Active: ${active.length}, Completed: ${completed.length}, Cancelled: ${cancelled.length}',
        );

        setState(() {
          activeOrders = active;
          completedOrders = completed;
          cancelledOrders = cancelled;
          isLoading = false;
        });
      } else {
        print(
          '❌ Failed to load orders: ${response['pesan'] ?? response['message']}',
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final priceInt = price is int ? price : (price as double).toInt();
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _reorderItems(Map<String, dynamic> order) async {
    try {
      // Ambil items dari order
      final List<dynamic> orderItems = order['fullItems'] ?? [];

      if (orderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada item untuk dipesan kembali'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Load existing cart
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cart_items');
      List<Map<String, dynamic>> cartItems = [];

      if (raw != null) {
        try {
          final List<dynamic> decoded = jsonDecode(raw);
          cartItems = decoded.cast<Map<String, dynamic>>();
        } catch (_) {}
      }

      // Add items from order to cart
      int addedCount = 0;
      for (var item in orderItems) {
        // Safely get values with null checks
        final menuId = item['menuId'] ?? item['idMenu'];
        if (menuId == null) continue; // Skip if no valid ID

        final menuName = (item['menuName'] ?? item['namaMenu'] ?? 'Pizza')
            .toString();

        // Get price as integer and format it properly
        final priceRaw = item['price'] ?? item['harga'] ?? 0;
        final priceInt = priceRaw is int
            ? priceRaw
            : (priceRaw is double ? priceRaw.toInt() : 0);
        final priceFormatted = 'Rp ${_formatPrice(priceInt)}';

        final quantity = item['quantity'] ?? item['jumlah'] ?? 1;
        final imageUrl =
            (item['imageUrl'] ??
                    item['gambar'] ??
                    'https://images.unsplash.com/photo-1513104890138-7c749659a591')
                .toString();

        // Check if item already exists in cart
        final existingIndex = cartItems.indexWhere(
          (cartItem) => cartItem['id'] == menuId,
        );

        if (existingIndex != -1) {
          // Update quantity
          final currentQty = cartItems[existingIndex]['quantity'] ?? 0;
          cartItems[existingIndex]['quantity'] = currentQty + quantity;
        } else {
          // Add new item with proper format matching cart screen expectations
          cartItems.add({
            'id': menuId,
            'name': menuName,
            'price': priceFormatted, // Format: "Rp 50.000"
            'quantity': quantity,
            'image': imageUrl,
          });
        }
        addedCount++;
      }

      // Save updated cart
      await prefs.setString('cart_items', jsonEncode(cartItems));

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount item berhasil ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to cart screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } catch (e) {
      print('❌ Error reordering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan ke keranjang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentOrders = _selectedTab == 0
        ? activeOrders
        : _selectedTab == 1
        ? completedOrders
        : cancelledOrders;

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
          'Pesanan Saya',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: () {
              _loadOrders(); // Refresh data
            },
            tooltip: 'Refresh',
          ),
        ],
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
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildTabButton('Aktif', 0),
                        const SizedBox(width: 10),
                        _buildTabButton('Selesai', 1),
                        const SizedBox(width: 10),
                        _buildTabButton('Dibatalkan', 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : _selectedTab == 1
                        ? _buildCompletedOrders()
                        : _selectedTab == 2
                        ? _buildCancelledOrders()
                        : (currentOrders.isEmpty
                              ? _buildEmptyState()
                              : _buildOrdersList(currentOrders)),
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
    return Expanded(
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 120, color: lightYellowColor),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Kamu belum punya\npesanan aktif\nsaat ini',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
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
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      order['img'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['date'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order['price'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['items'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show cancel button only for PENDING and DIPROSES status
              Row(
                children: [
                  if (order['status'] == 'PENDING' ||
                      order['status'] == 'DIPROSES')
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CancelOrderScreen(
                                  orderId: order['id'],
                                  orderName: order['name'],
                                  orderPrice: order['price'],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Batalkan Pesanan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (order['status'] == 'PENDING' ||
                      order['status'] == 'DIPROSES')
                    const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryTimeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Lacak Driver',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }

  Widget _buildCompletedOrders() {
    if (completedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada pesanan selesai',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        final order = completedOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      order['img'] ??
                          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 65,
                          height: 65,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.local_pizza,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['name'] ?? 'Order',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['date'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pesanan Selesai',
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
                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order['price'] ?? 'Rp 0',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['items'] ?? '0 items',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () {
                          // Check if user already submitted review
                          if (order['hasReview'] == true) {
                            // Navigate to View Review Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewReviewScreen(
                                  productName: order['name'] ?? 'Order',
                                  productImage:
                                      order['img'] ??
                                      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
                                  rating: order['reviewRating'] ?? 5,
                                  comment: order['reviewComment'] ?? '',
                                  reviewDate: order['reviewDate'] != null
                                      ? _formatDate(order['reviewDate'])
                                      : null,
                                ),
                              ),
                            ).then(
                              (_) => _loadOrders(),
                            ); // Refresh after viewing
                          } else {
                            // Navigate to Leave Review Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaveReviewScreen(
                                  productName: order['name'] ?? 'Order',
                                  productImage:
                                      order['img'] ??
                                      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
                                  orderId:
                                      order['id'], // Pass orderId for backend API
                                ),
                              ),
                            ).then(
                              (_) => _loadOrders(),
                            ); // Refresh after submitting review
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          order['hasReview'] == true
                              ? 'Lihat Review'
                              : 'Beri Review',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 3),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: () => _reorderItems(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Pesan Lagi',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelledOrders() {
    if (cancelledOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan dibatalkan',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: cancelledOrders.length,
      itemBuilder: (context, index) {
        final order = cancelledOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  order['img'] ??
                      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_pizza, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['name'] ?? 'Order',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['date'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cancel, size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Pesanan dibatalkan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order['price'] ?? 'Rp 0',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['items'] ?? '0 items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
