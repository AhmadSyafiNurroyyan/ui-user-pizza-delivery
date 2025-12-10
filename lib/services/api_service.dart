import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend URL Railway
  static const String baseUrl = 'https://pizza-delivery.up.railway.app';

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // ============================================
  // Helper: Get JWT Token dari SharedPreferences
  // ============================================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ============================================
  // Helper: Save JWT Token ke SharedPreferences
  // ============================================
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // ============================================
  // Helper: Remove JWT Token dari SharedPreferences
  // ============================================
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ============================================
  // Helper: Build Headers dengan JWT Token
  // ============================================
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================
  // POST Request (untuk Register, Login, Orders, dll.)
  // ============================================
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      print('🚀 POST Request: $url');
      print('📋 Headers: $headers');
      print('📦 Body: ${jsonEncode(body)}');

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');

      // Handle empty response body
      Map<String, dynamic> responseData;
      if (response.body.isEmpty) {
        responseData = {
          'success': false,
          'message':
              'Server returned empty response (Status: ${response.statusCode})',
        };
      } else {
        responseData = jsonDecode(response.body);

        // Jika ada token di response, save token
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
        }
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      print('❌ POST Error: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // ============================================
  // GET Request (untuk Menu, Orders History, dll.)
  // ============================================
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      print('🚀 GET Request: $url');

      final response = await http.get(url, headers: headers).timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      // Handle empty response body
      Map<String, dynamic> responseData;
      if (response.body.isEmpty) {
        responseData = {
          'success': false,
          'message':
              'Server returned empty response (Status: ${response.statusCode})',
        };
      } else {
        responseData = jsonDecode(response.body);
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      print('❌ GET Error: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // ============================================
  // PATCH Request (untuk Update Review, Profile, dll.)
  // ============================================
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      print('🚀 PATCH Request: $url');
      print('📦 Body: ${jsonEncode(body)}');

      final response = await http
          .patch(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      print('❌ PATCH Error: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // ============================================
  // PUT Request (untuk Update data lengkap)
  // ============================================
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      print('🚀 PUT Request: $url');
      print('📦 Body: ${jsonEncode(body)}');

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      print('❌ PUT Error: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // ============================================
  // DELETE Request
  // ============================================
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      print('🚀 DELETE Request: $url');

      final response = await http
          .delete(url, headers: headers)
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      print('❌ DELETE Error: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // ============================================
  // API METHODS - AUTHENTICATION
  // ============================================

  /// Register user baru
  /// POST /api/register
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
  }) async {
    return await post('/api/register', {
      'nama': nama,
      'email': email,
      'password': password,
      'noHp': noHp,
      'role': 'USER', // Default role for user registration
    });
  }

  /// Login user
  /// POST /api/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await post('/api/login', {'email': email, 'password': password});
  }

  /// Forgot Password - Request reset token
  /// POST /api/forgot-password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await post('/api/forgot-password', {'email': email});
  }

  /// Reset Password dengan token
  /// POST /api/reset-password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await post('/api/reset-password', {
      'token': token,
      'newPassword': newPassword,
    });
  }

  /// Change Password (untuk user yang sudah login - tanpa email/token)
  /// POST /api/auth/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String passwordBaru,
    required String konfirmasiPassword,
  }) async {
    return await post(
      '/api/auth/change-password',
      {
        'email': email,
        'passwordBaru': passwordBaru,
        'konfirmasiPassword': konfirmasiPassword,
      },
      requiresAuth: false, // Tidak butuh JWT token, pakai email langsung
    );
  }

  // ============================================
  // API METHODS - MENU
  // ============================================

  /// Get semua menu pizza
  /// GET /api/menu
  static Future<Map<String, dynamic>> getMenu() async {
    return await get('/api/menu');
  }

  // ============================================
  // API METHODS - OUTLETS
  // ============================================

  /// Get semua outlets
  /// GET /api/outlets
  static Future<Map<String, dynamic>> getOutlets() async {
    return await get('/api/outlets');
  }

  // ============================================
  // API METHODS - ORDERS
  // ============================================

  /// Create order baru
  /// POST /api/orders
  static Future<Map<String, dynamic>> createOrder({
    required int outletId,
    required String alamatKirim,
    required List<Map<String, dynamic>> items,
    String? catatan,
    String? metodeBayar,
  }) async {
    return await post('/api/orders', {
      'idOutlet': outletId, // Backend expect 'idOutlet', bukan 'outletId'
      'alamatKirim': alamatKirim,
      'items': items,
      if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      if (metodeBayar != null) 'metodeBayar': metodeBayar,
    }, requiresAuth: true);
  }

  /// Get order history user (customer)
  /// GET /api/me/orders
  static Future<Map<String, dynamic>> getMyOrders() async {
    return await get('/api/me/orders', requiresAuth: true);
  }

  /// Cancel order
  /// POST /api/orders/{orderId}/cancel
  static Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    String endpoint = '/api/orders/$orderId/cancel';
    if (reason != null && reason.isNotEmpty) {
      endpoint += '?reason=${Uri.encodeComponent(reason)}';
    }
    return await post(endpoint, {}, requiresAuth: true);
  }

  /// Update payment method untuk order
  /// POST /api/orders/{orderId}/payment
  static Future<Map<String, dynamic>> updatePayment({
    required int orderId,
    required String paymentMethod,
  }) async {
    return await post('/api/orders/$orderId/payment', {
      'metodeBayar': paymentMethod,
    }, requiresAuth: true);
  }

  // ============================================
  // API METHODS - REVIEWS
  // ============================================

  /// Submit review untuk order
  /// PATCH /api/me/orders/{orderId}/review
  static Future<Map<String, dynamic>> submitReview({
    required int orderId,
    required int rating,
    String? komentar,
  }) async {
    return await patch('/api/me/orders/$orderId/review', {
      'rating': rating,
      if (komentar != null && komentar.isNotEmpty) 'komentar': komentar,
    }, requiresAuth: true);
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Check apakah user sudah login (ada token)
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user (clear token)
  static Future<void> logout() async {
    await clearToken();
  }
}
