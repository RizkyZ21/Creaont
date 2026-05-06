import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool isLoading = false;

  // ── Getter token dari SharedPreferences ───────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // ── Login ─────────────────────────────────────────────────────────
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await AuthService.login(email: email, password: password);

      isLoading = false;
      notifyListeners();

      // Backend sekarang return 'success' (bukan 'status')
      if (res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user  = res['user']  as Map<String, dynamic>? ?? {};

        await prefs.setString('token', res['token'] ?? '');
        await prefs.setString('name',  user['name']  ?? 'User');
        await prefs.setString('role',  user['role']  ?? 'customer');
        await prefs.setString('email', user['email'] ?? email);
        await prefs.setInt('user_id',  user['id']    ?? 0);

        final role = user['role'] ?? 'customer';

        if (!context.mounted) return;

        if (role == 'customer') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'designer') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? 'Login gagal')),
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ── Register ──────────────────────────────────────────────────────
  Future<void> register(
    String name,
    String email,
    String password,
    String role,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await AuthService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil! Silakan login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final msg = res['message'];
        final errorText = msg is Map
            ? msg.values.expand((e) => e is List ? e : [e]).join('\n')
            : msg?.toString() ?? 'Register gagal';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText)),
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout(BuildContext context) async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      await AuthService.logout(token: token);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
