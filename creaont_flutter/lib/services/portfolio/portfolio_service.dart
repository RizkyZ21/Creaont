import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class PortfolioService {
  // ── Ambil semua portfolio (public) ────────────────────────────────
  static Future<Map<String, dynamic>> getPortfolios() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.portfolioUrl),
        headers: ApiService.headers(),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Buat portfolio baru (designer) ────────────────────────────────
  static Future<Map<String, dynamic>> createPortfolio({
    required String token,
    required String title,
    required String description,
    required String category,
    required double price,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.portfolioUrl),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'title':       title,
          'description': description,
          'category':    category,
          'price':       price,
          if (image != null) 'image': image,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Update portfolio ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> updatePortfolio({
    required String token,
    required int id,
    String? title,
    String? description,
    String? category,
    double? price,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiService.portfolioDetailUrl(id)),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          if (title != null)       'title': title,
          if (description != null) 'description': description,
          if (category != null)    'category': category,
          if (price != null)       'price': price,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Hapus portfolio ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> deletePortfolio({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiService.portfolioDetailUrl(id)),
        headers: ApiService.headers(token: token),
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
      // Backend bisa return List langsung (index) atau Map
      if (decoded is List) return {'success': true, 'data': decoded};
      return decoded as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
