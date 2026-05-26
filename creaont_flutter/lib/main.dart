import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_page.dart';
import 'screens/dashboard/customer_dashboard.dart';
import 'screens/dashboard/designer_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek apakah sudah ada token (auto-login)
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final role = prefs.getString('role') ?? 'customer';
  final initialRoute = token.isEmpty
      ? '/login'
      : role == 'admin'
          ? '/admin-dashboard'
          : '/home';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creaont',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D71FD),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // ── Route awal ──────────────────────────────────────
      initialRoute: initialRoute,

      // ── Named routes ────────────────────────────────────
      routes: {
        '/login':              (_) => const LoginScreen(),
        '/register':           (_) => const RegisterScreen(),
        '/home':               (_) => const HomePage(),
        '/customer-dashboard': (_) => const CustomerDashboardScreen(),
        '/dashboard':          (_) => const DesignerDashboardScreen(),
        '/admin-dashboard':    (_) => const AdminDashboardScreen(),
      },
    );
  }
}
