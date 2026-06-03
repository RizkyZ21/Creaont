import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/order/order_service.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/review/review_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final String token;
  final String role;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.token,
    required this.role,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? order;
  bool isLoading       = true;
  bool isDownloading   = false;
  // Review state
  bool hasReviewed     = false;
  bool isSubmittingReview = false;
  int  _selectedRating = 5;
  final _commentCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await OrderService.getOrderDetail(
        token: widget.token, orderId: widget.orderId);
    if (mounted) {
      setState(() {
        isLoading = false;
        order     = res['success'] == true ? (res['data'] ?? res['order']) : null;
      });
    }
    // Cek review status kalau customer & completed
    if (widget.role != 'designer' && order?['status'] == 'completed') {
      _checkReview();
    }
  }

  Future<void> _checkReview() async {
    final res = await ReviewService.checkReview(
        token: widget.token, orderId: widget.orderId);
    if (mounted) {
      setState(() => hasReviewed = res['has_reviewed'] == true);
    }
  }

  Future<void> _updateStatus(String status) async {
    final res = await OrderService.updateOrder(
        token: widget.token, orderId: widget.orderId, status: status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Status diperbarui'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ));
      if (res['success'] == true) _load();
    }
  }

  Future<void> _updateProgress(int progress) async {
    await OrderService.updateOrder(
        token: widget.token, orderId: widget.orderId, progress: progress);
    _load();
  }

  Future<void> _submitReview() async {
    setState(() => isSubmittingReview = true);
    final res = await ReviewService.submitReview(
      token:   widget.token,
      orderId: widget.orderId,
      rating:  _selectedRating,
      comment: _commentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => isSubmittingReview = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message'] ?? (res['success'] == true ? 'Review terkirim!' : 'Gagal')),
      backgroundColor: res['success'] == true ? Colors.green : Colors.red,
    ));
    if (res['success'] == true) {
      setState(() => hasReviewed = true);
      _commentCtrl.clear();
    }
  }

  Future<void> _downloadFile() async {
    final portfolioId = order?['portfolio']?['id'];
    if (portfolioId == null) return;

    setState(() => isDownloading = true);
    final res = await PortfolioService.downloadRawFile(
        token: widget.token, portfolioId: portfolioId);
    if (!mounted) return;
    setState(() => isDownloading = false);

    if (res['success'] == true) {
      _triggerDownload(res['bytes'] as Uint8List, res['filename'] as String);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Download gagal'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _triggerDownload(Uint8List bytes, String filename) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(kIsWeb
          ? 'File "$filename" siap didownload.'
          : 'File "$filename" berhasil didownload.'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ));
  }

  bool get _canDownload {
    final status = order?['status'];
    final hasRaw = order?['portfolio']?['raw_file_type'] != null;
    return widget.role != 'designer' && hasRaw &&
        (status == 'completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Order', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : order == null
              ? const Center(child: Text('Order tidak ditemukan',
                  style: TextStyle(color: Colors.white54)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoCard(),
                        const SizedBox(height: 16),
                        _progressCard(),
                        if (_canDownload) ...[
                          const SizedBox(height: 16),
                          _downloadCard(),
                        ],
                        if (widget.role == 'designer') ...[
                          const SizedBox(height: 16),
                          _designerActions(),
                        ],
                        if (widget.role != 'designer') ...[
                          const SizedBox(height: 16),
                          _customerActions(),
                        ],
                        // Review section — customer, order completed
                        if (widget.role != 'designer' && order!['status'] == 'completed') ...[
                          const SizedBox(height: 16),
                          hasReviewed ? _reviewDoneCard() : _reviewFormCard(),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _infoCard() {
    final status  = order!['status'] ?? '';
    final title   = order!['portfolio']?['title'] ?? 'Order #${order!['id']}';
    final price   = order!['total_price'] ?? 0;
    final deadline= order!['deadline'];
    final rawType = order!['portfolio']?['raw_file_type'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1B3A), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('#ORD-${order!['id']}',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          _badge(status),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        _row('Designer', order!['designer']?['name'] ?? '-'),
        _row('Customer', order!['customer']?['name'] ?? '-'),
        _row('Harga',    'Rp ${_fmt(price)}'),
        if (deadline != null)
          _row('Deadline', deadline.toString().split('T')[0]),
        if (rawType != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.insert_drive_file, color: Colors.purpleAccent, size: 14),
            const SizedBox(width: 4),
            Text('File raw: .${rawType.toString().toUpperCase()}',
                style: const TextStyle(color: Colors.purpleAccent, fontSize: 12)),
          ]),
        ],
      ]),
    );
  }

  Widget _progressCard() {
    final progress = (order!['progress'] ?? 0) as int;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1B3A), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progress',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$progress%',
              style: const TextStyle(
                  color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white10,
            color: Colors.purpleAccent,
            minHeight: 10,
          ),
        ),
        if (widget.role == 'designer' && order!['status'] == 'in_progress') ...[
          const SizedBox(height: 12),
          Row(
            children: [10, 25, 50, 75, 100].map((p) => Expanded(
              child: GestureDetector(
                onTap: () => _updateProgress(p),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: progress >= p ? Colors.purple : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$p',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: progress >= p ? Colors.white : Colors.white54,
                          fontSize: 12)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          const Center(child: Text('Tap untuk update progress',
              style: TextStyle(color: Colors.white38, fontSize: 11))),
        ],
      ]),
    );
  }

  Widget _downloadCard() {
    final rawType = order!['portfolio']?['raw_file_type']?.toString().toUpperCase() ?? 'FILE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withValues(alpha: 0.2), Colors.deepPurple.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.download_rounded, color: Colors.purpleAccent),
          SizedBox(width: 8),
          Text('File Desain',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 8),
        Text('File raw (.$rawType) tersedia untuk didownload.',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isDownloading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download),
            label: Text(isDownloading ? 'Mengunduh...' : 'Download .$rawType'),
            onPressed: (isDownloading) ? null : _downloadFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              disabledBackgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Rating form (customer, completed, belum review) ──────────────────
  Widget _reviewFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.star, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Text('Beri Rating', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 4),
        const Text('Bagaimana pengalamanmu dengan order ini?',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 16),

        // Star selector
        Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    star <= _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              );
            })),
        const SizedBox(height: 6),
        Center(child: Text(
          _ratingLabel(_selectedRating),
          style: const TextStyle(color: Colors.amber, fontSize: 13),
        )),
        const SizedBox(height: 16),

        // Comment
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tulis ulasan kamu (opsional)...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmittingReview ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              disabledBackgroundColor: Colors.amber.withValues(alpha: 0.3),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: isSubmittingReview
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('Kirim Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _reviewDoneCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
    ),
    child: const Row(children: [
      Icon(Icons.check_circle, color: Colors.green),
      SizedBox(width: 10),
      Text('Kamu sudah memberikan rating untuk order ini.',
          style: TextStyle(color: Colors.green)),
    ]),
  );

  Widget _designerActions() {
    final status = order!['status'];
    return Column(children: [
      if (status == 'pending')
        _btn('Mulai Pengerjaan', Colors.blue, () => _updateStatus('in_progress')),
      if (status == 'in_progress') ...[
        const SizedBox(height: 8),
        _btn('Tandai Selesai', Colors.green, () => _updateStatus('completed')),
      ],
      if (status == 'revision')
        _btn('Mulai Revisi', Colors.orange, () => _updateStatus('in_progress')),
    ]);
  }

  Widget _customerActions() {
    final status = order!['status'];
    return Column(children: [
      if (status == 'in_progress')
        _btn('Minta Revisi', Colors.orange, () => _updateStatus('revision')),
      if (status == 'in_progress' || status == 'revision')
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _btn('Selesaikan Order', Colors.green, () => _updateStatus('completed')),
        ),
      if (status == 'pending')
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _btn('Batalkan Order', Colors.red, () => _updateStatus('cancelled')),
        ),
    ]);
  }

  // ─────────── Helpers ───────────────────────────────────────────────
  Widget _btn(String label, Color color, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white54)),
      Text(value, style: const TextStyle(color: Colors.white)),
    ]),
  );

  Widget _badge(String status) {
    Color c; String lbl;
    switch (status) {
      case 'pending':     c = Colors.orange; lbl = 'Pending'; break;
      case 'in_progress': c = Colors.blue;   lbl = 'In Progress'; break;
      case 'revision':    c = Colors.yellow; lbl = 'Revision'; break;
      case 'completed':   c = Colors.green;  lbl = 'Completed'; break;
      case 'cancelled':   c = Colors.red;    lbl = 'Cancelled'; break;
      default:            c = Colors.grey;   lbl = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(lbl, style: TextStyle(color: c, fontSize: 12)),
    );
  }

  String _fmt(dynamic price) {
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Sangat Buruk 😞';
      case 2: return 'Buruk 😕';
      case 3: return 'Cukup 😐';
      case 4: return 'Bagus 😊';
      case 5: return 'Luar Biasa! 🤩';
      default: return '';
    }
  }
}
