import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/config.dart';

class ApiService {
  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${Config.baseUrl}/login"),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    return _handleResponse(response);
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse("${Config.baseUrl}/register"),
      headers: {"Accept": "application/json"},
      body: {"name": name, "email": email, "password": password, "role": role},
    );

    return _handleResponse(response);
  }

  // ================= HANDLE RESPONSE =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        return {
          "status": false,
          "message": data['message'] ?? "Terjadi kesalahan",
        };
      }
    } catch (e) {
      return {"status": false, "message": "Invalid response dari server"};
    }
  }
}
