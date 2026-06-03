import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/payment/payment_service.dart';
import 'payment_status_screen.dart';

class InvoiceScreen extends StatefulWidget {
  final String title;
  final String price;
  final int? orderId;
  final String token;

  const InvoiceScreen({
    super.key,
    required this.title,
    required this.price,
    this.orderId,
    this.token = '',
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String paymentMethod = 'QRIS';
  bool isLoading = false;

  final methods = ['QRIS', 'DANA', 'GoPay', 'Transfer Bank'];

  Future<void> _pay() async {
    if (widget.orderId == null || widget.token.isEmpty) {
      _snack('Order belum valid', Colors.red);
      return;
    }

    setState(() => isLoading = true);
    final res = await PaymentService.createSnapToken(
      token: widget.token,
      orderId: widget.orderId!,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (res['success'] != true) {
      _snack(res['message'] ?? 'Gagal membuat pembayaran', Colors.red);
      return;
    }

    final redirectUrl = res['redirect_url']?.toString();
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final uri = Uri.parse(redirectUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _snack('Tidak bisa membuka payment gateway', Colors.red);
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusScreen(
          title: widget.title,
          price: widget.price,
          method: 'Payment Gateway',
          orderId: widget.orderId,
          token: widget.token,
        ),
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Invoice', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Order info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _row('Layanan', widget.title),
                  const Divider(color: Colors.white12),
                  _row('Total', widget.price, bold: true, highlight: true),
                  if (widget.orderId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Order ID: #${widget.orderId}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment methods
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Metode Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...methods.map(
              (m) => GestureDetector(
                onTap: () => setState(() => paymentMethod = m),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: paymentMethod == m
                        ? Colors.purple.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: paymentMethod == m
                          ? Colors.purpleAccent
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _methodIcon(m),
                        color: paymentMethod == m
                            ? Colors.purpleAccent
                            : Colors.white54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        m,
                        style: TextStyle(
                          color: paymentMethod == m
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: paymentMethod == m
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (paymentMethod == m)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.purpleAccent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Bayar via $paymentMethod',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool highlight = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.purpleAccent : Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 16 : 14,
          ),
        ),
      ],
    ),
  );

  IconData _methodIcon(String m) {
    switch (m) {
      case 'QRIS':
        return Icons.qr_code;
      case 'DANA':
        return Icons.account_balance_wallet;
      case 'GoPay':
        return Icons.payment;
      case 'Transfer Bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}
