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

      print("LOGIN RESPONSE: $res"); // 🔥 DEBUG

      isLoading = false;
      notifyListeners();

      if (res['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);

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

      print("LOGIN ERROR: $e");

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
    String role, // 🔥 TAMBAH
    BuildContext context,
    ) async {
        isLoading = true;
        notifyListeners();

    try {
        final res = await ApiService.register(name, email, password, role);

        print("REGISTER RESPONSE: $res");

        isLoading = false;
        notifyListeners();

        if (res['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Register berhasil")),
        );

        Navigator.pop(context);
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Gagal')),
        );
        }
    } catch (e) {
        isLoading = false;
        notifyListeners();

        print(e);

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
        );
    }
    }
}
