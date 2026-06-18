// PATH: creaont_flutter/lib/screens/order/history_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/order/order_service.dart';
import 'order_detail_screen.dart';

class HistoryTransactionScreen extends StatefulWidget {
  const HistoryTransactionScreen({super.key});

  @override
  State<HistoryTransactionScreen> createState() => _HistoryTransactionScreenState();
}

class _HistoryTransactionScreenState extends State<HistoryTransactionScreen> {
  List<dynamic> completedOrders = [];
  bool isLoading = true;
  String token   = '';
  int myUserId   = 0;

  @override
  void initState() {
    super.initState();
    _init();
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

    // Ambil semua order yang sudah selesai (completed)
    final all = res['success'] == true ? (res['data'] as List) : [];
    setState(() {
      isLoading       = false;
      completedOrders = all.where((o) => o['status'] == 'completed').toList();
    });
  }

  /// Tentukan peran saya di order ini berdasarkan customer_id vs myUserId
  String _myRoleInOrder(dynamic order) {
    final customerId = order['customer']?['id'] ?? order['customer_id'];
    return (customerId != null && customerId == myUserId) ? 'customer' : 'designer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Transaction History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
          : completedOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64),
                      SizedBox(height: 16),
                      Text('Belum ada transaksi selesai',
                          style: TextStyle(color: Colors.white54, fontSize: 15)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: completedOrders.length,
                    itemBuilder: (_, i) => _HistoryCard(
                      order:       completedOrders[i],
                      myRoleInOrder: _myRoleInOrder(completedOrders[i]),
                      token:       token,
                      myUserId:    myUserId,
                    ),
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic order;
  final String  myRoleInOrder;
  final String  token;
  final int     myUserId;

  const _HistoryCard({
    required this.order,
    required this.myRoleInOrder,
    required this.token,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    final title      = order['portfolio']?['title'] ?? 'Order #${order['id']}';
    final price      = order['total_price'] ?? 0;
    final isService  = order['type'] == 'service';
    final isBuyer    = myRoleInOrder == 'customer';

    // Nama pihak lain
    final otherName  = isBuyer
        ? (order['designer']?['name'] ?? 'Designer')
        : (order['customer']?['name'] ?? 'Customer');

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId:  order['id'],
          token:    token,
          myUserId: myUserId,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F3C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon tipe order
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isService
                    ? Colors.blue.withValues(alpha: 0.15)
                    : const Color(0xFF0288D1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isService ? Icons.design_services : Icons.image_outlined,
                color: isService ? Colors.blueAccent : Colors.lightBlueAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Chip: Pembeli / Penjual
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: (isBuyer ? Colors.amber : Colors.lightBlueAccent)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBuyer ? 'Pembelian' : 'Penjualan',
                          style: TextStyle(
                            color: isBuyer ? Colors.amber : Colors.lightBlueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isBuyer ? 'dari $otherName' : 'ke $otherName',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_fmtDate(order['updated_at']),
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Harga + arah transaksi
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isBuyer ? '-' : '+'} Rp ${_fmt(price)}',
                  style: TextStyle(
                    color: isBuyer ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic price) {
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _fmtDate(String? raw) {
    if (raw == null) return '-';
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day} ${_months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '-';
    }
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
}
