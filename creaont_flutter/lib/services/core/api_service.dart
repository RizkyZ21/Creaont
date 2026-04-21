import 'package:flutter/foundation.dart';

class ApiService {
  // Base URL otomatis sesuai platform
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web / Chrome
      return 'http://127.0.0.1:8000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:8000/api';
  }

  // Helper endpoint auth
  static String get loginUrl => '$baseUrl/login';
  static String get registerUrl => '$baseUrl/register';
  static String get logoutUrl => '$baseUrl/logout';

  // Helper endpoint dashboard / order
  static String get ordersUrl => '$baseUrl/orders';
  static String get portfolioUrl => '$baseUrl/portfolios';
  static String get chatUrl => '$baseUrl/chat';
  static String get paymentUrl => '$baseUrl/payment';

  // Dynamic endpoint
  static String orderDetailUrl(int id) => '$baseUrl/orders/$id';
  static String chatRoomUrl(int orderId) => '$baseUrl/chat/$orderId';
}