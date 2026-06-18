// PATH: creaont_flutter/lib/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../order/order_detail_screen.dart';
import '../chat/chat_room_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh list saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F3C),
        title: Consumer<NotificationProvider>(
          builder: (_, p, _) => Text(
            'Notifikasi${p.unreadCount > 0 ? " (${p.unreadCount})" : ""}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, p, _) {
              if (p.notifications.isEmpty) return const SizedBox();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1A3660),
                onSelected: (val) {
                  if (val == 'read_all') p.markAllAsRead();
                  if (val == 'delete_all') _confirmDeleteAll(context, p);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'read_all',
                    child: Text(
                      'Tandai semua dibaca',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Text(
                      'Hapus semua',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
            );
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xFF1E90FF),
            onRefresh: () => provider.fetchNotifications(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  provider.notifications.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == provider.notifications.length) {
                  // Load more trigger
                  provider.fetchNotifications();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E90FF),
                      ),
                    ),
                  );
                }
                final notif = provider.notifications[i];
                return _NotifTile(
                  notif: notif,
                  onTap: () => _handleTap(context, provider, notif),
                  onDelete: () => provider.deleteNotification(notif.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    NotificationProvider provider,
    NotificationModel notif,
  ) async {
    await provider.markAsRead(notif.id);

    final orderId = notif.orderId;
    if (orderId == null) return;

    final prefs    = await SharedPreferences.getInstance();
    final token    = prefs.getString('token')  ?? '';
    // FIXED: ambil myUserId untuk diteruskan ke layar anak,
    // sehingga penentuan role di order tertentu dilakukan berdasarkan ID,
    // bukan role global akun (yang salah saat desainer beli ke desainer lain).
    final myUserId = prefs.getInt('user_id')   ?? 0;
    final myRole   = prefs.getString('role')   ?? 'customer'; // tetap diperlukan untuk ChatRoomScreen.myRole

    if (!context.mounted) return;

    switch (notif.type) {
      case 'new_message':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              orderId:   orderId,
              otherName: notif.data['sender_name']?.toString() ?? 'Chat',
              orderTitle: 'Order #$orderId',
              token:     token,
              myRole:    myRole,
              // FIXED: pass myUserId agar isMe di bubble chat pakai sender.id
              myUserId:  myUserId,
            ),
          ),
        );
        break;
      case 'order_placed':
      case 'rating_received':
      case 'progress_updated':
        Navigator.push(
          context,
          MaterialPageRoute(
            // FIXED: OrderDetailScreen sekarang pakai myUserId, bukan role string
            builder: (_) => OrderDetailScreen(
              orderId:  orderId,
              token:    token,
              myUserId: myUserId,
            ),
          ),
        );
        break;
    }
  }

  void _confirmDeleteAll(BuildContext context, NotificationProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A3660),
        title: const Text(
          'Hapus Semua?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Semua notifikasi akan dihapus permanen.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              p.deleteAll();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile notifikasi dengan swipe-to-delete ────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead
                ? const Color(0xFF0D1F3C)
                : const Color(0xFF1A3660),
            borderRadius: BorderRadius.circular(12),
            border: notif.isRead
                ? null
                : Border.all(
                    color: const Color(0xFF1E90FF).withValues(alpha: 0.4),
                    width: 1,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: notif.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E90FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notif.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;
    switch (notif.type) {
      case 'order_placed':
        icon = Icons.shopping_bag_outlined;
        color = const Color(0xFF2ECC71);
        break;
      case 'rating_received':
        icon = Icons.star_outline_rounded;
        color = const Color(0xFFFFD700);
        break;
      case 'progress_updated':
        icon = Icons.update_rounded;
        color = const Color(0xFF1E90FF);
        break;
      case 'new_message':
        icon = Icons.chat_bubble_outline_rounded;
        color = const Color(0xFF9B59B6);
        break;
      default:
        icon = Icons.notifications_outlined;
        color = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
