import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Backend returned HTML error page'
      };
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Backend returned HTML error page'
      };
    }

    return jsonDecode(response.body);
  }
}