import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class OrderService {
  static Future<Map<String, dynamic>> getOrders({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.ordersUrl),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.orderDetailUrl(orderId)),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required int portfolioId,
    required String deadline,
    required int estimatedDays,
    required double totalPrice,
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.ordersUrl),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'portfolio_id':   portfolioId,
          'deadline':       deadline,
          'estimated_days': estimatedDays,
          'total_price':    totalPrice,
          'description':    description,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateOrder({
    required String token,
    required int orderId,
    String? status,
    int? progress,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiService.orderDetailUrl(orderId)),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          if (status != null)   'status': status,
          if (progress != null) 'progress': progress,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response response) {
    if (response.body.trim().startsWith('<')) {
      return {'success': false, 'message': 'Server error (${response.statusCode})'};
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
