import 'package:flutter/material.dart';
import '../../services/order/order_service.dart';
import 'invoice_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final String title;
  final String price;
  final int portfolioId;
  final String portfolioType;
  final String token;

  const CreateOrderScreen({
    super.key,
    required this.title,
    required this.price,
    required this.portfolioId,
    this.portfolioType = 'design',
    required this.token,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _descCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '3');
  bool _loading = false;

  bool get _isService => widget.portfolioType == 'service';

  double get _priceNum {
    final clean = widget.price.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0;
  }

  String get _deadlineStr {
    final days = int.tryParse(_daysCtrl.text) ?? 3;
    final d = DateTime.now().add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final days = int.tryParse(_daysCtrl.text) ?? 0;
    if (_isService && days < 1) {
      _snack('Estimasi hari minimal 1', Colors.orange);
      return;
    }

    setState(() => _loading = true);

    final res = await OrderService.createOrder(
      token: widget.token,
      portfolioId: widget.portfolioId,
      deadline: _isService ? _deadlineStr : null,
      estimatedDays: _isService ? days : null,
      totalPrice: _priceNum,
      description: _isService ? _descCtrl.text.trim() : '',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      final order = res['data'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceScreen(
            title: widget.title,
            price: widget.price,
            orderId: order?['id'],
            token: widget.token,
          ),
        ),
      );
    } else {
      _snack(res['message'] ?? 'Gagal membuat order', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0288D1).withValues(alpha: 0.3),
                    const Color(0xFF0277BD).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.portfolioType == 'service'
                              ? 'SERVICE'
                              : 'DESAIN JADI',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isService) ...[
              _label('Catatan untuk Designer (opsional)'),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Warna preferensi, ukuran file, format yang diinginkan...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Estimasi Hari Pengerjaan'),
              TextField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '3',
                  hintStyle: const TextStyle(color: Colors.white38),
                  suffixText: 'hari',
                  suffixStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: _daysCtrl,
                builder: (context, value, child) {
                  final days = int.tryParse(_daysCtrl.text) ?? 0;
                  if (days < 1) return const SizedBox.shrink();
                  final d = DateTime.now().add(Duration(days: days));
                  final label = '${d.day} ${_months[d.month - 1]} ${d.year}';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          color: Colors.lightBlueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Deadline: $label',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.file_download_done, color: Colors.greenAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Setelah pembayaran berhasil, file raw langsung bisa didownload.',
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Ringkasan biaya
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _row(
                    _isService ? 'Harga Jasa' : 'Harga Desain',
                    widget.price,
                  ),
                  _row('Biaya Platform', 'Gratis'),
                  const Divider(color: Colors.white24),
                  _row('Total Bayar', widget.price, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  disabledBackgroundColor: const Color(0xFF0288D1).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Lanjut ke Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(
          value,
          style: TextStyle(
            color: bold ? Colors.lightBlueAccent : Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 15 : 14,
          ),
        ),
      ],
    ),
  );

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
}
