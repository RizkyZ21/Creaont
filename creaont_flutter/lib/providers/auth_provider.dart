import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import '../screens/home/home_page.dart';

class AuthProvider with ChangeNotifier {
  bool isLoading = false;

  // ================= LOGIN =================
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.login(email, password);

      isLoading = false;
      notifyListeners();

      if (res['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // 🔥 AMBIL DATA USER DENGAN AMAN
        final user = res['user'] ?? {};

        final token = res['token'] ?? '';
        final name = user['name'] ?? 'User';
        final role = user['role'] ?? 'customer';
        final userEmail = user['email'] ?? email; // 🔥 TAMBAH INI

        // 🔥 SIMPAN KE LOCAL
        await prefs.setString('token', token);
        await prefs.setString('name', name);
        await prefs.setString('role', role);
        await prefs.setString('email', userEmail); // 🔥 TAMBAH INI

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= REGISTER =================
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
      final res = await ApiService.register(name, email, password, role);

      isLoading = false;
      notifyListeners();

      if (res['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Register berhasil")));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal')));
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= LOGOUT =================
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }
}
