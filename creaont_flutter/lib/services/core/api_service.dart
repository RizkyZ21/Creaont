import 'package:flutter/foundation.dart';

/// Satu-satunya ApiService untuk seluruh app.
/// Ganti file lama di lib/core/services/api_service.dart dan
/// lib/services/core/api_service.dart dengan file ini.
class ApiService {
  // ── Base URL otomatis sesuai platform ─────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web (Chrome)
      return 'http://127.0.0.1:8000/api';
    }
    // Android Emulator  → 10.0.2.2
    // iOS Simulator     → 127.0.0.1
    // Physical device   → ganti dengan IP lokal laptop (contoh: 192.168.1.5)
    return 'http://10.0.2.2:8000/api';
  }

  // ── Auth endpoints ────────────────────────────────────────────────
  static String get loginUrl       => '$baseUrl/login';
  static String get registerUrl    => '$baseUrl/register';
  static String get logoutUrl      => '$baseUrl/logout';
  static String get meUrl          => '$baseUrl/me';
  static String get updateProfile  => '$baseUrl/update-profile';

  // ── Order endpoints ───────────────────────────────────────────────
  static String get ordersUrl                   => '$baseUrl/orders';
  static String orderDetailUrl(int id)          => '$baseUrl/orders/$id';

  // ── Portfolio endpoints ───────────────────────────────────────────
  static String get portfolioUrl                => '$baseUrl/portfolios';
  static String portfolioDetailUrl(int id)      => '$baseUrl/portfolios/$id';

  // ── Chat endpoints ────────────────────────────────────────────────
  static String get chatSendUrl                 => '$baseUrl/chat/send';
  static String chatRoomUrl(int orderId)        => '$baseUrl/chat/$orderId';

  // ── Helper header ─────────────────────────────────────────────────
  static Map<String, String> headers({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }
}
