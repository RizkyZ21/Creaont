import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class ChatService {
  // ── Ambil pesan dalam room order tertentu ─────────────────────────
  static Future<Map<String, dynamic>> getMessages({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.chatRoomUrl(orderId)),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Kirim pesan baru ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int orderId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.chatSendUrl),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'order_id': orderId,
          'message':  message,
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
      final decoded = jsonDecode(response.body);
      if (decoded is List) return {'success': true, 'data': decoded};
      return decoded as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
