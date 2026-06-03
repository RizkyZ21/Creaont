import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class PaymentService {
  static Future<Map<String, dynamic>> createSnapToken({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.paymentSnapTokenUrl),
        headers: ApiService.headers(token: token),
        body: jsonEncode({'order_id': orderId}),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatus({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.paymentStatusUrl(orderId)),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response response) {
    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Server error (${response.statusCode})',
      };
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
