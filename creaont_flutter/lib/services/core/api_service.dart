import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return 'http://10.0.2.2:8000/api';
  }

  static String get storageUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/storage';
    return 'http://10.0.2.2:8000/storage';
  }

  // Auth
  static String get loginUrl => '$baseUrl/login';
  static String get registerUrl => '$baseUrl/register';
  static String get logoutUrl => '$baseUrl/logout';
  static String get meUrl => '$baseUrl/me';
  static String get updateProfile => '$baseUrl/update-profile';
  static String get upgradeToDesignerUrl => '$baseUrl/upgrade-to-designer';

  // Orders
  static String get ordersUrl => '$baseUrl/orders';
  static String orderDetailUrl(int id) => '$baseUrl/orders/$id';
  static String orderCompleteServiceUrl(int id) =>
      '$baseUrl/orders/$id/complete-service';
  static String orderDeliveryDownloadUrl(int id) =>
      '$baseUrl/orders/$id/delivery/download';

  // Portfolio
  static String get portfolioUrl => '$baseUrl/portfolios';
  static String get portfolioPopularUrl => '$baseUrl/portfolios/popular';
  static String get servicesUrl => '$baseUrl/services';
  static String get categoriesUrl => '$baseUrl/categories';
  static String get myPortfoliosUrl => '$baseUrl/my-portfolios';
  static String portfolioDetailUrl(int id) => '$baseUrl/portfolios/$id';
  static String portfolioByDesigner(int id) =>
      '$baseUrl/portfolios/designer/$id';
  static String portfolioDownloadUrl(int id) =>
      '$baseUrl/portfolios/$id/download';

  // Payment
  static String get paymentSnapTokenUrl => '$baseUrl/payments/snap-token';
  static String paymentStatusUrl(int orderId) =>
      '$baseUrl/payments/$orderId/status';

  // Chat
  static String get chatSendUrl => '$baseUrl/chat/send';
  static String chatRoomUrl(int orderId) => '$baseUrl/chat/$orderId';

  // Admin
  static String get adminSummaryUrl => '$baseUrl/admin/summary';

  // Image URL helper
  static String imageUrl(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^storage/+'), '');

    return '$storageUrl/$normalized';
  }

  static Map<String, String> headers({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Map<String, String> headersMultipart({String? token}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }
}
