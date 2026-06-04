import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification/notification_model.dart';
import '../services/notification/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _token;

  // Polling timer (setiap 30 detik cek unread count)
  Timer? _pollingTimer;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // ── Init / set token ────────────────────────────────────────────────
  void init(String token) {
    _token = token;
    _reset();
    fetchNotifications();
    _startPolling();
  }

  void _reset() {
    _notifications = [];
    _currentPage = 1;
    _hasMore = true;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_token != null) _refreshUnreadCount();
    });
  }

  // ── Refresh hanya unread count (ringan, untuk badge) ────────────────
  Future<void> _refreshUnreadCount() async {
    if (_token == null) return;
    try {
      _unreadCount = await NotificationService.getUnreadCount(token: _token!);
      notifyListeners();
    } catch (_) {}
  }

  // ── Fetch list notifikasi ────────────────────────────────────────────
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_token == null) return;
    if (_isLoading) return;
    if (!_hasMore && !refresh) return;

    if (refresh) _reset();

    _isLoading = true;
    notifyListeners();

    try {
      final result = await NotificationService.getNotifications(
        token: _token!,
        page: _currentPage,
      );

      final newItems = result['notifications'] as List<NotificationModel>;
      _unreadCount = result['unread_count'] as int;
      final meta = result['meta'] as Map<String, dynamic>;

      if (refresh) {
        _notifications = newItems;
      } else {
        _notifications = [..._notifications, ...newItems];
      }

      final lastPage = meta['last_page'] as int? ?? 1;
      _hasMore = _currentPage < lastPage;
      if (_hasMore) _currentPage++;
    } catch (e) {
      debugPrint('NotificationProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Tandai satu sebagai dibaca ───────────────────────────────────────
  Future<void> markAsRead(String id) async {
    if (_token == null) return;
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || _notifications[idx].isRead) return;

    try {
      await NotificationService.markAsRead(token: _token!, notificationId: id);

      // Update state lokal
      final old = _notifications[idx];
      final updated = NotificationModel(
        id: old.id,
        type: old.type,
        title: old.title,
        body: old.body,
        data: old.data,
        readAt: DateTime.now(),
        createdAt: old.createdAt,
      );
      _notifications[idx] = updated;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  // ── Tandai semua dibaca ──────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    if (_token == null) return;
    try {
      await NotificationService.markAllAsRead(token: _token!);
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              data: n.data,
              readAt: n.readAt ?? DateTime.now(),
              createdAt: n.createdAt,
            ),
          )
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }

  // ── Hapus satu notifikasi ────────────────────────────────────────────
  Future<void> deleteNotification(String id) async {
    if (_token == null) return;
    try {
      await NotificationService.deleteNotification(
        token: _token!,
        notificationId: id,
      );
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx == -1) return;
      final removed = _notifications[idx];
      _notifications.removeWhere((n) => n.id == id);
      if (!removed.isRead && _unreadCount > 0) _unreadCount--;
      notifyListeners();
    } catch (e) {
      debugPrint('deleteNotification error: $e');
    }
  }

  // ── Hapus semua ──────────────────────────────────────────────────────
  Future<void> deleteAll() async {
    if (_token == null) return;
    try {
      await NotificationService.deleteAll(token: _token!);
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('deleteAll error: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
