import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/order/order_service.dart';
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
  // Upload file hasil jasa (designer)
  PlatformFile? _deliveryFile;
  bool _isUploading = false;

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

  Future<void> _pickDeliveryFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null || file.bytes!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal membaca file, coba lagi'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
    setState(() => _deliveryFile = file);
  }

  Future<void> _uploadDeliveryFile() async {
    if (_deliveryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih file hasil terlebih dahulu'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        title: const Text('Kirim Hasil Kerja',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Upload "${_deliveryFile!.name}" sebagai hasil jasa?\n\nOrder akan otomatis ditandai selesai.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upload & Selesai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isUploading = true);
    final res = await OrderService.completeServiceOrder(
      token: widget.token,
      orderId: widget.orderId,
      deliveryFile: _deliveryFile!,
    );
    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (res['success'] == true) _deliveryFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message'] ??
          (res['success'] == true ? 'File berhasil diupload!' : 'Gagal upload')),
      backgroundColor: res['success'] == true ? Colors.green : Colors.red,
    ));
    if (res['success'] == true) _load();
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
    setState(() => isDownloading = true);
    final res = await OrderService.downloadDeliveryFile(
        token: widget.token, orderId: widget.orderId);
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
    final hasDelivery = order?['latest_design_file'] != null;
    return widget.role != 'designer' &&
        status == 'completed' &&
        hasDelivery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Order', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlueAccent))
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
          color: const Color(0xFF0D1F3C), borderRadius: BorderRadius.circular(16)),
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
            const Icon(Icons.insert_drive_file, color: Colors.lightBlueAccent, size: 14),
            const SizedBox(width: 4),
            Text('File raw: .${rawType.toString().toUpperCase()}',
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
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
          color: const Color(0xFF0D1F3C), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progress',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$progress%',
              style: const TextStyle(
                  color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white10,
            color: Colors.lightBlueAccent,
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
                    color: progress >= p ? const Color(0xFF0288D1) : Colors.white10,
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
          // ── Upload file hasil (service only) ────────────────────
          if (order!['type'] == 'service') ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.upload_file, color: Colors.lightBlueAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  'Kirim File Hasil Jasa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload file hasil kerja untuk menyelesaikan order.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            // Pilih file
            GestureDetector(
              onTap: _isUploading ? null : _pickDeliveryFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _deliveryFile != null
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.lightBlueAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: _deliveryFile == null
                    ? Row(
                        children: const [
                          Icon(Icons.attach_file,
                              color: Colors.lightBlueAccent, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap untuk pilih file hasil kerja',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white24),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.insert_drive_file,
                                color: Colors.green, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _deliveryFile!.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fmtSize(_deliveryFile!.size),
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _deliveryFile = null),
                            child: const Icon(Icons.close,
                                color: Colors.white38, size: 18),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                    _isUploading ? 'Mengupload...' : 'Upload & Selesaikan Order'),
                onPressed:
                    (_isUploading || _deliveryFile == null) ? null : _uploadDeliveryFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ]),
    );
  }

  Widget _downloadCard() {
    final deliveryFile = order!['latest_design_file'] as Map<String, dynamic>?;
    final fileType = (deliveryFile?['file_type'] ?? 'file').toString().toUpperCase();
    final fileName = deliveryFile?['file_name'] ?? 'File Hasil Jasa';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0288D1).withValues(alpha: 0.2), const Color(0xFF0277BD).withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.download_rounded, color: Colors.lightBlueAccent),
          SizedBox(width: 8),
          Text('File Hasil Jasa',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.insert_drive_file, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('.$fileType',
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isDownloading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download),
            label: Text(isDownloading ? 'Mengunduh...' : 'Download File Hasil'),
            onPressed: (isDownloading) ? null : _downloadFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
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
        color: const Color(0xFF0D1F3C),
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
    final isService = order!['type'] == 'service';
    return Column(children: [
      if (status == 'pending')
        _btn('Mulai Pengerjaan', Colors.blue, () => _updateStatus('in_progress')),
      // Untuk jasa: "Tandai Selesai" disembunyikan — diselesaikan via upload file di progress card
      if (status == 'in_progress' && !isService) ...[
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
  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
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
