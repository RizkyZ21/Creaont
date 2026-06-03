import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../order/order_detail_screen.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String title;
  final String price;
  final String method;
  final int? orderId;
  final String token;
  final String initialStatus; // 'paid' | 'failed' | 'pending'

  const PaymentStatusScreen({
    super.key,
    required this.title,
    required this.price,
    required this.method,
    this.orderId,
    this.token = '',
    this.initialStatus = 'paid',
  });

  @override
  Widget build(BuildContext context) {
    final paid   = initialStatus == 'paid';
    final failed = initialStatus == 'failed';

    final color = paid
        ? Colors.green
        : failed
            ? Colors.redAccent
            : Colors.orangeAccent;
    final icon = paid
        ? Icons.check_circle_rounded
        : failed
            ? Icons.cancel_rounded
            : Icons.schedule_rounded;
    final titleText = paid
        ? 'Pembayaran Berhasil!'
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
                // Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Icon(icon, color: color, size: 58),
                ),
                const SizedBox(height: 28),

                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paid
                      ? 'Order untuk "$title" telah dikonfirmasi\ndan siap diproses.'
                      : failed
                          ? 'Terjadi kesalahan saat memproses pembayaran.'
                          : 'Pembayaran belum dikonfirmasi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),

                const SizedBox(height: 28),

                // Summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row('Metode',  method),
                      _row('Total',   price),
                      if (orderId != null) _row('Order ID', '#$orderId'),
                      _row('Status',
                          paid ? 'LUNAS ✓' : failed ? 'GAGAL ✗' : 'PENDING'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Lihat Order button (jika paid & ada orderId)
                if (paid && orderId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Lihat Detail Order',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(
                            orderId: orderId!,
                            token:   token,
                            role:    'customer',
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (r) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Kembali ke Beranda'),
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
        Text(value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
