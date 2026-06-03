import 'package:flutter/material.dart';
import '../../services/payment/payment_service.dart';
import '../home/home_page.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String title;
  final String price;
  final String method;
  final int? orderId;
  final String token;

  const PaymentStatusScreen({
    super.key,
    required this.title,
    required this.price,
    required this.method,
    this.orderId,
    this.token = '',
  });

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool isLoading = false;
  String paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (widget.orderId == null || widget.token.isEmpty) return;
    setState(() => isLoading = true);
    final res = await PaymentService.getStatus(
      token: widget.token,
      orderId: widget.orderId!,
    );
    if (!mounted) return;
    setState(() {
      isLoading = false;
      if (res['success'] == true) {
        paymentStatus = res['payment_status']?.toString() ?? 'pending';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paid = paymentStatus == 'paid';
    final failed = paymentStatus == 'failed';
    final color = paid
        ? Colors.green
        : failed
        ? Colors.redAccent
        : Colors.orangeAccent;
    final icon = paid
        ? Icons.check
        : failed
        ? Icons.close
        : Icons.schedule;
    final title = paid
        ? 'Pembayaran Berhasil'
        : failed
        ? 'Pembayaran Gagal'
        : 'Menunggu Pembayaran';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 50),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paid
                      ? 'Order untuk "${widget.title}" telah dikonfirmasi.'
                      : 'Selesaikan pembayaran di halaman gateway, lalu refresh status.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row('Metode', widget.method),
                      _row('Total', widget.price),
                      if (widget.orderId != null)
                        _row('Order ID', '#${widget.orderId}'),
                      _row('Status', paymentStatus.toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                    onPressed: isLoading ? null : _loadStatus,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (r) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
