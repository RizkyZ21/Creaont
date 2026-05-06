import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class AuthService {
  // ── Register ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.registerUrl),
        headers: ApiService.headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Login ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.loginUrl),
        headers: ApiService.headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logout({required String token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.logoutUrl),
        headers: ApiService.headers(token: token),
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Update Profile ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String email,
    String? bio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.updateProfile),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'name': name,
          'email': email,
          if (bio != null) 'bio': bio,
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Parse response helper ─────────────────────────────────────────
  static Map<String, dynamic> _parseResponse(http.Response response) {
    // Jika server return HTML (error page PHP/Laravel)
    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Server error (${response.statusCode})',
      };
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (_) {
      return {
        'success': false,
        'message': 'Response tidak valid dari server',
      };
    }
  }
}
