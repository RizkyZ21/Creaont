import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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
        body: jsonEncode({'email': email, 'password': password}),
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
    XFile? avatar,
  }) async {
    try {
      if (avatar != null) {
        final bytes = await avatar.readAsBytes();
        final mime = _mimeFromBytes(bytes);
        final dio = Dio(
          BaseOptions(
            headers: ApiService.headersMultipart(token: token),
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        final response = await dio.post(
          ApiService.updateProfile,
          data: FormData.fromMap({
            'name': name,
            'email': email,
            if (bio != null) 'bio': bio,
            'avatar': MultipartFile.fromBytes(
              bytes,
              filename: 'avatar.${mime.subtype}',
              contentType: DioMediaType(mime.type, mime.subtype),
            ),
          }),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {
          'success': false,
          'message': 'Response tidak valid dari server',
        };
      }

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

  static MediaType _mimeFromBytes(List<int> bytes) {
    if (bytes.length >= 12) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return MediaType('image', 'png');
      }
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
    }
    return MediaType('image', 'jpeg');
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
      return {'success': false, 'message': 'Response tidak valid dari server'};
    }
  }
}
