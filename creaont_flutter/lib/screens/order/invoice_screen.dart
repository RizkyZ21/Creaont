// PATH: creaont_flutter/lib/screens/order/invoice_screen.dart

import 'package:flutter/material.dart';
import '../../services/payment/payment_service.dart';
import '../payment/payment_status_screen.dart';

class InvoiceScreen extends StatefulWidget {
  final String title;
  final String price;
  final int?   orderId;
  final String token;
  // FIXED: tambah myUserId supaya bisa diteruskan ke PaymentStatusScreen
  // → OrderDetailScreen, agar role ditentukan dari ID bukan hardcoded string
  final int myUserId;

  const InvoiceScreen({
    super.key,
    required this.title,
    required this.price,
    this.orderId,
    this.token    = '',
    this.myUserId = 0,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String _selectedMethod = 'QRIS';
  bool   _isLoading      = false;

  static const _methods = [
    {'id': 'QRIS',          'label': 'QRIS',          'icon': Icons.qr_code,               'sub': 'Semua e-wallet & bank'},
    {'id': 'DANA',          'label': 'DANA',           'icon': Icons.account_balance_wallet, 'sub': 'Bayar via DANA'},
    {'id': 'GoPay',         'label': 'GoPay',          'icon': Icons.payment,               'sub': 'Bayar via GoPay'},
    {'id': 'Transfer Bank', 'label': 'Transfer Bank',  'icon': Icons.account_balance,       'sub': 'BCA / Mandiri / BRI / BNI'},
  ];

  Future<void> _pay() async {
    if (widget.orderId == null || widget.token.isEmpty) {
      _goToStatus('failed');
      return;
    }

    setState(() => _isLoading = true);

    final res = await PaymentService.createSnapToken(
      token:   widget.token,
      orderId: widget.orderId!,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    _goToStatus(res['success'] == true ? 'paid' : 'failed');
  }

  void _goToStatus(String status) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusScreen(
          title:         widget.title,
          price:         widget.price,
          method:        _selectedMethod,
          orderId:       widget.orderId,
          token:         widget.token,
          initialStatus: status,
          // FIXED: teruskan myUserId ke PaymentStatusScreen
          myUserId:      widget.myUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pembayaran', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
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
                        const Text('Ringkasan Order',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 10),
                        Text(widget.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Bayar',
                                style: TextStyle(color: Colors.white70)),
                            Text(widget.price,
                                style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                        if (widget.orderId != null) ...[
                          const SizedBox(height: 4),
                          Text('Order #${widget.orderId}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Pilih Metode Pembayaran',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 12),
                  // Payment methods
                  ...(_methods.map((m) {
                    final id     = m['id']    as String;
                    final label  = m['label'] as String;
                    final icon   = m['icon']  as IconData;
                    final sub    = m['sub']   as String;
                    final active = _selectedMethod == id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0288D1).withValues(alpha: 0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                active ? Colors.lightBlueAccent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF0288D1).withValues(alpha: 0.3)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon,
                                color: active
                                    ? Colors.lightBlueAccent
                                    : Colors.white54,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: TextStyle(
                                        color:
                                            active ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.bold)),
                                Text(sub,
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (active)
                            const Icon(Icons.check_circle,
                                color: Colors.lightBlueAccent, size: 20),
                        ]),
                      ),
                    );
                  }).toList()),
                ],
              ),
            ),
          ),

          // Pay button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  disabledBackgroundColor:
                      const Color(0xFF0288D1).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Bayar via $_selectedMethod',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
