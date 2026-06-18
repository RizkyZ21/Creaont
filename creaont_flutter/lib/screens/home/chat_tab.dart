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
  List<_ConvThread> threads         = [];
  List<_ConvThread> filteredThreads = [];
  bool isLoading = true;
  String token   = '';
  int myUserId   = 0;

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
    token    = prefs.getString('token')  ?? '';
    myUserId = prefs.getInt('user_id')   ?? 0;
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

    final Map<String, _ConvThread> map = {};

    for (final o in rawOrders) {
      final customerId   = o['customer']?['id'] ?? 0;
      final designerId   = o['designer']?['id'] ?? 0;

      final int    otherId;
      final String otherName;
      final String myRoleInOrder;

      if (customerId == myUserId) {
        myRoleInOrder = 'customer';
        otherId   = designerId;
        otherName = o['designer']?['name'] ?? 'Designer';
      } else {
        myRoleInOrder = 'designer';
        otherId   = customerId;
        otherName = o['customer']?['name'] ?? 'Customer';
      }

      final type = (o['type'] ?? 'design') as String;
      final key  = '${otherId}_$type';

      if (!map.containsKey(key)) {
        map[key] = _ConvThread(
          key:          key,
          otherUserId:  otherId,
          otherName:    otherName,
          type:         type,
          latestOrder:  o,
          orderIds:     [],
          myRoleInLatestOrder: myRoleInOrder,
        );
      }
      map[key]!.orderIds.add(o['id'] as int);
    }

    final built = map.values.toList();

    setState(() {
      isLoading       = false;
      threads         = built;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Messages', style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  _circleIcon(Icons.refresh, _load),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari percakapan...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () { _searchCtrl.clear(); _search(''); })
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
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
                  : filteredThreads.isEmpty
                      ? const Center(child: Text('Belum ada percakapan',
                          style: TextStyle(color: Colors.white54)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: filteredThreads.length,
                              itemBuilder: (_, i) => _ThreadTile(
                              thread: filteredThreads[i],
                              token: token,
                              myUserId: myUserId,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Color(0xFF0D1F3C), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

// ── Data class ─────────────────────────────────────────────────────────
class _ConvThread {
  final String key;
  final int    otherUserId;
  final String otherName;
  final String type;
  final dynamic latestOrder;
  final List<int> orderIds;
  final String myRoleInLatestOrder;

  _ConvThread({
    required this.key,
    required this.otherUserId,
    required this.otherName,
    required this.type,
    required this.latestOrder,
    required this.orderIds,
    required this.myRoleInLatestOrder,
  });
}

// ── Tile widget ────────────────────────────────────────────────────────
class _ThreadTile extends StatelessWidget {
  final _ConvThread thread;
  final String token;
  final int myUserId;

  const _ThreadTile({
    super.key,
    required this.thread,
    required this.token,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    final order          = thread.latestOrder;
    final status         = order['status'] as String? ?? '';
    final portfolioTitle = order['portfolio']?['title'] ?? 'Order';
    final isService      = thread.type == 'service';
    final orderCount     = thread.orderIds.length;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          orderId: order['id'] as int,
          otherName: thread.otherName,
          orderTitle:
              isService
                  ? 'Jasa — $portfolioTitle'
                  : 'Desain Jadi',
          token: token,

          myRole: thread.myRoleInLatestOrder,

          myUserId: myUserId,

          groupOrderIds: thread.orderIds,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F3C),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Avatar + badge jumlah order
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: isService
                      ? Colors.blue.withValues(alpha: 0.6)
                      : const Color(0xFF0288D1).withValues(alpha: 0.6),
                  child: Text(
                    thread.otherName.isNotEmpty
                        ? thread.otherName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (orderCount > 1)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0D1F3C), width: 1.5),
                      ),
                      child: Center(child: Text('$orderCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9))),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(thread.otherName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      // Label kecil: saya sebagai apa di thread ini
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: (thread.myRoleInLatestOrder == 'customer'
                              ? Colors.amber
                              : Colors.lightBlueAccent).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          thread.myRoleInLatestOrder == 'customer' ? 'Pembeli' : 'Designer',
                          style: TextStyle(
                            color: thread.myRoleInLatestOrder == 'customer'
                                ? Colors.amber
                                : Colors.lightBlueAccent,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isService
                              ? Colors.blue.withValues(alpha: 0.2)
                              : const Color(0xFF0288D1).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isService ? 'Jasa' : 'Desain Jadi',
                          style: TextStyle(
                            color: isService ? Colors.blueAccent : Colors.lightBlueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          orderCount > 1 ? '$orderCount order' : portfolioTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_statusLabel(status),
                  style: TextStyle(color: _statusColor(status), fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Color  _statusColor(String s) {
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
