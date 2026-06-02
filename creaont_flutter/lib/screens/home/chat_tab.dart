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
  List<dynamic> orders = [];
  List<dynamic> filtered = [];
  bool isLoading = true;
  String token = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    role  = prefs.getString('role') ?? 'customer';
    await _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await OrderService.getOrders(token: token);
    if (mounted) {
      setState(() {
        isLoading = false;
        // Only show orders yang statusnya bukan cancelled
        orders = res['success'] == true
            ? (res['data'] as List).where((o) => o['status'] != 'cancelled').toList()
            : [];
        filtered = orders;
      });
    }
  }

  void _search(String q) {
    final query = q.toLowerCase();
    setState(() {
      filtered = orders.where((o) {
        final other = role == 'designer'
            ? (o['customer']?['name'] ?? '').toLowerCase()
            : (o['designer']?['name'] ?? '').toLowerCase();
        final title = (o['portfolio']?['title'] ?? '').toLowerCase();
        return other.contains(query) || title.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Messages', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  _circleIcon(Icons.more_vert),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari percakapan...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1B3A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                  : filtered.isEmpty
                      ? const Center(child: Text('Belum ada percakapan', style: TextStyle(color: Colors.white54)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final order = filtered[i];
                              final other = role == 'designer'
                                  ? order['customer']
                                  : order['designer'];
                              final otherName = other?['name'] ?? 'User';
                              final title = order['portfolio']?['title'] ?? 'Order #${order['id']}';

                              return GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    orderId: order['id'],
                                    otherName: otherName,
                                    orderTitle: title,
                                    token: token,
                                    myRole: role,
                                  ),
                                )),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1B3A),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.purple,
                                        child: Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                                            style: const TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(otherName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(order['status']).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(order['status'] ?? '',
                                            style: TextStyle(color: _statusColor(order['status']), fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'in_progress': return Colors.blue;
      case 'completed':   return Colors.green;
      case 'pending':     return Colors.orange;
      case 'revision':    return Colors.yellow;
      default:            return Colors.grey;
    }
  }

  Widget _circleIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(color: Color(0xFF1E1B3A), shape: BoxShape.circle),
    child: Icon(icon, color: Colors.white),
  );
}
