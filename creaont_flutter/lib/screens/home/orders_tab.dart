import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/order/order_service.dart';
import '../order/order_detail_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int selectedTab = 0;
  final tabs = ['Active', 'Completed', 'Cancelled'];
  List<dynamic> allOrders = [];
  bool isLoading = true;
  String token = '';
  String role  = '';

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
        allOrders = res['success'] == true ? (res['data'] as List) : [];
      });
    }
  }

  List<dynamic> get _filtered {
    switch (selectedTab) {
      case 0: return allOrders.where((o) => ['pending','in_progress','revision'].contains(o['status'])).toList();
      case 1: return allOrders.where((o) => o['status'] == 'completed').toList();
      case 2: return allOrders.where((o) => o['status'] == 'cancelled').toList();
      default: return [];
    }
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
                  const Text('Orders', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  _circleIcon(Icons.refresh, _load),
                ],
              ),
            ),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final active = selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = i),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        children: [
                          Text(tabs[i], style: TextStyle(
                            color: active ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.bold,
                          )),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 3, width: active ? 30 : 0,
                            decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(10)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                  : _filtered.isEmpty
                      ? Center(child: Text('Tidak ada order ${tabs[selectedTab].toLowerCase()}',
                          style: const TextStyle(color: Colors.white54)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _OrderCard(
                              order: _filtered[i],
                              role: role,
                              token: token,
                              onRefresh: _load,
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
      decoration: const BoxDecoration(color: Color(0xFF1E1B3A), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String role;
  final String token;
  final VoidCallback onRefresh;

  const _OrderCard({required this.order, required this.role, required this.token, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final status   = order['status'] ?? '';
    final title    = order['portfolio']?['title'] ?? 'Order #${order['id']}';
    final customerMap = order['customer'] as Map?;
    final designerMap = order['designer'] as Map?;
    final dynamic other;
    if (role == 'designer') {
      other = customerMap != null ? customerMap['name'] : null;
    } else {
      other = designerMap != null ? designerMap['name'] : null;
    }
    final progress = (order['progress'] ?? 0) as int;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order['id'], token: token, role: role),
      )).then((_) => onRefresh()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1B3A), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#ORD-${order['id']} • ${_fmtDate(order['created_at'])}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                _StatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            if (other != null) ...[
              const SizedBox(height: 2),
              Text('${role == 'designer' ? 'Customer' : 'by'}: $other',
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
            if (status == 'in_progress') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.white10,
                        color: Colors.purpleAccent,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$progress%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(String? raw) {
    if (raw == null) return '-';
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day} ${_months[d.month - 1]} ${d.year}';
    } catch (_) { return '-'; }
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color c; String label;
    switch (status) {
      case 'pending':     c = Colors.orange;  label = 'Pending'; break;
      case 'in_progress': c = Colors.blue;    label = 'In Progress'; break;
      case 'revision':    c = Colors.yellow;  label = 'Revision'; break;
      case 'completed':   c = Colors.green;   label = 'Completed'; break;
      case 'cancelled':   c = Colors.red;     label = 'Cancelled'; break;
      default:            c = Colors.grey;    label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
