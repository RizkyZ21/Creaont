import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';
import '../../models/notification/notification_model.dart';

class NotificationService {
  // ── Fetch all notifications (paginated) ─────────────────────────────
  static Future<Map<String, dynamic>> getNotifications({
    required String token,
    int page = 1,
  }) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/notifications?page=$page'),
      headers: ApiService.headers(token: token),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && body['success'] == true) {
      final rawList = body['data'] as List<dynamic>? ?? [];
      return {
        'notifications': rawList
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        'unread_count': body['unread_count'] as int? ?? 0,
        'meta': body['meta'] as Map<String, dynamic>? ?? {},
      };
    }
    throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
  }

  // ── Unread count (untuk badge) ───────────────────────────────────────
  static Future<int> getUnreadCount({required String token}) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/notifications/unread-count'),
      headers: ApiService.headers(token: token),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['unread_count'] as int? ?? 0;
    }
    return 0;
  }

  // ── Mark one as read ────────────────────────────────────────────────
  static Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    await http.post(
      Uri.parse('${ApiService.baseUrl}/notifications/$notificationId/read'),
      headers: ApiService.headers(token: token),
    );
  }

  // ── Mark all as read ────────────────────────────────────────────────
  static Future<void> markAllAsRead({required String token}) async {
    await http.post(
      Uri.parse('${ApiService.baseUrl}/notifications/read-all'),
      headers: ApiService.headers(token: token),
    );
  }

  // ── Delete one ──────────────────────────────────────────────────────
  static Future<void> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    await http.delete(
      Uri.parse('${ApiService.baseUrl}/notifications/$notificationId'),
      headers: ApiService.headers(token: token),
    );
  }

  // ── Delete all ──────────────────────────────────────────────────────
  static Future<void> deleteAll({required String token}) async {
    await http.delete(
      Uri.parse('${ApiService.baseUrl}/notifications'),
      headers: ApiService.headers(token: token),
    );
  }
}
