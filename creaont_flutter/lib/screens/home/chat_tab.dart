import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/order/order_service.dart';
import '../chat/chat_room_screen.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _searchCtrl = TextEditingController();
  // Grouped conversations: key = "userId_type" (e.g. "12_design")
  // value = list semua order yang masuk ke group itu (ambil yang terbaru)
  List<_ConvThread> threads = [];
  List<_ConvThread> filteredThreads = [];
  bool isLoading = true;
  String token = '';
  String role = '';
  int myUserId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    token    = prefs.getString('token') ?? '';
    role     = prefs.getString('role') ?? 'customer';
    myUserId = prefs.getInt('user_id') ?? 0;
    await _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await OrderService.getOrders(token: token);
    if (!mounted) return;

    final rawOrders = res['success'] == true
        ? (res['data'] as List)
            .where((o) => o['status'] != 'cancelled')
            .toList()
        : <dynamic>[];

    // ── Group logic ─────────────────────────────────────────────────
    // Key: "<other_user_id>_<type>"  (type = design | service)
    // Setiap key maks tampil 1 thread (chat gabungan), ambil order terbaru
    // sebagai representatif title & status.
    final Map<String, _ConvThread> map = {};

    for (final o in rawOrders) {
      final otherId = role == 'designer'
          ? (o['customer']?['id'] ?? 0)
          : (o['designer']?['id'] ?? 0);
      final otherName = role == 'designer'
          ? (o['customer']?['name'] ?? 'User')
          : (o['designer']?['name'] ?? 'User');
      final type = (o['type'] ?? 'design') as String;
      final key = '${otherId}_$type';

      if (!map.containsKey(key)) {
        map[key] = _ConvThread(
          key: key,
          otherUserId: otherId,
          otherName: otherName,
          type: type,
          // representatif order = yang paling baru (list sudah latest())
          latestOrder: o,
          orderIds: [],
        );
      }
      map[key]!.orderIds.add(o['id'] as int);
    }

    final built = map.values.toList();

    setState(() {
      isLoading = false;
      threads = built;
      filteredThreads = built;
    });
  }

  void _search(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      filteredThreads = query.isEmpty
          ? threads
          : threads.where((t) {
              return t.otherName.toLowerCase().contains(query) ||
                  (t.latestOrder['portfolio']?['title'] ?? '')
                      .toLowerCase()
                      .contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _circleIcon(Icons.more_vert),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari percakapan...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.white38),
                          onPressed: () {
                            _searchCtrl.clear();
                            _search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF0D1F3C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.lightBlueAccent))
                  : filteredThreads.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada percakapan',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: filteredThreads.length,
                            itemBuilder: (_, i) =>
                                _ThreadTile(
                              thread: filteredThreads[i],
                              role: role,
                              token: token,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) => Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1F3C),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      );
}

// ── Data class untuk 1 thread conversation ────────────────────────────
class _ConvThread {
  final String key;
  final int otherUserId;
  final String otherName;
  final String type; // 'design' | 'service'
  final dynamic latestOrder;
  final List<int> orderIds;

  _ConvThread({
    required this.key,
    required this.otherUserId,
    required this.otherName,
    required this.type,
    required this.latestOrder,
    required this.orderIds,
  });
}

// ── Tile widget per thread ────────────────────────────────────────────
class _ThreadTile extends StatelessWidget {
  final _ConvThread thread;
  final String role;
  final String token;

  const _ThreadTile({
    required this.thread,
    required this.role,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final order = thread.latestOrder;
    final status = order['status'] as String? ?? '';
    final portfolioTitle =
        order['portfolio']?['title'] ?? 'Order';
    final isService = thread.type == 'service';
    final orderCount = thread.orderIds.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            // Kirim orderId yang paling representatif (terbaru)
            orderId: order['id'] as int,
            otherName: thread.otherName,
            orderTitle: isService ? '🎨 Jasa — $portfolioTitle' : '📦 Desain Jadi',
            token: token,
            myRole: role,
            // Pass semua orderIds supaya ChatRoom bisa load semua chat
            groupOrderIds: thread.orderIds,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F3C),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: isService
                      ? Colors.blue.withValues(alpha: 0.6)
                      : const Color(0xFF0288D1).withValues(alpha: 0.6),
                  child: Text(
                    thread.otherName.isNotEmpty
                        ? thread.otherName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                // Badge jumlah order jika > 1
                if (orderCount > 1)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0D1F3C), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '$orderCount',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.otherName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isService
                              ? Colors.blue.withValues(alpha: 0.2)
                              : const Color(0xFF0288D1).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isService ? 'Jasa' : 'Desain Jadi',
                          style: TextStyle(
                            color: isService
                                ? Colors.blueAccent
                                : Colors.lightBlueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          orderCount > 1
                              ? '$orderCount order'
                              : portfolioTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    _statusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                    color: _statusColor(status), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'in_progress': return Colors.blue;
      case 'completed':   return Colors.green;
      case 'pending':     return Colors.orange;
      case 'revision':    return Colors.yellow;
      default:            return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'in_progress': return 'In Progress';
      case 'completed':   return 'Selesai';
      case 'pending':     return 'Pending';
      case 'revision':    return 'Revisi';
      default:            return s;
    }
  }
}
