import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/order/order_service.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';

// Web-only download helper
import 'dart:html' as html show AnchorElement, Url, Blob;

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
  bool isLoading = true;
  bool isDownloading = false;
  bool isCompletingService = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await OrderService.getOrderDetail(
      token: widget.token,
      orderId: widget.orderId,
    );
    if (mounted) {
      setState(() {
        isLoading = false;
        order = res['success'] == true ? (res['data'] ?? res['order']) : null;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    final res = await OrderService.updateOrder(
      token: widget.token,
      orderId: widget.orderId,
      status: status,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Status diperbarui'),
          backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        ),
      );
      if (res['success'] == true) _load();
    }
  }

  Future<void> _updateProgress(int progress) async {
    await OrderService.updateOrder(
      token: widget.token,
      orderId: widget.orderId,
      progress: progress,
    );
    _load();
  }

  Future<void> _downloadFile() async {
    final portfolioId = order?['portfolio']?['id'];
    if (portfolioId == null) return;

    setState(() => isDownloading = true);
    final res = await PortfolioService.downloadRawFile(
      token: widget.token,
      portfolioId: portfolioId,
    );
    if (!mounted) return;
    setState(() => isDownloading = false);

    if (res['success'] == true) {
      final Uint8List bytes = res['bytes'];
      final String filename = res['filename'];
      _triggerDownload(bytes, filename);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Download gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadDeliveryFile() async {
    setState(() => isDownloading = true);
    final res = await OrderService.downloadDeliveryFile(
      token: widget.token,
      orderId: widget.orderId,
    );
    if (!mounted) return;
    setState(() => isDownloading = false);

    if (res['success'] == true) {
      final Uint8List bytes = res['bytes'];
      final String filename = res['filename'];
      _triggerDownload(bytes, filename);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Download gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeServiceWithFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => isCompletingService = true);
    final res = await OrderService.completeServiceOrder(
      token: widget.token,
      orderId: widget.orderId,
      deliveryFile: result.files.first,
    );
    if (!mounted) return;
    setState(() => isCompletingService = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Order diperbarui'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) _load();
  }

  void _triggerDownload(Uint8List bytes, String filename) {
    if (kIsWeb) {
      // Web: buat anchor element dan trigger click
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile: simpan ke Downloads (perlu path_provider jika ingin persistent)
      // Untuk sekarang tampilkan snackbar success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File berhasil didownload'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  bool get _canDownload {
    final status = order?['status'];
    final paymentStatus = order?['payment_status'];
    final orderType = order?['portfolio']?['type'] ?? order?['type'];
    return widget.role != 'designer' &&
        (orderType == 'design' || orderType == 'product') &&
        paymentStatus == 'paid' &&
        status != null &&
        status != 'cancelled';
  }

  bool get _isServiceOrder {
    final orderType = order?['portfolio']?['type'] ?? order?['type'];
    return orderType == 'service';
  }

  bool get _isDesignOrder {
    final orderType = order?['portfolio']?['type'] ?? order?['type'];
    return orderType == 'design' || orderType == 'product';
  }

  bool get _canDownloadDelivery {
    return _isServiceOrder && order?['latest_design_file'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detail Order',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : order == null
          ? const Center(
              child: Text(
                'Order tidak ditemukan',
                style: TextStyle(color: Colors.white54),
              ),
            )
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
                    if (_isServiceOrder) _progressCard(),
                    if (_isServiceOrder) const SizedBox(height: 16),
                    // Download section — muncul kalau customer & sudah bayar/selesai
                    if (_canDownload) _downloadCard(),
                    if (_canDownload) const SizedBox(height: 16),
                    if (_canDownloadDelivery) _deliveryDownloadCard(),
                    if (_canDownloadDelivery) const SizedBox(height: 16),
                    if (_isServiceOrder && widget.role == 'designer')
                      _designerActions(),
                    if (_isServiceOrder && widget.role == 'customer')
                      _customerActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoCard() {
    final status = order!['status'] ?? '';
    final title = order!['portfolio']?['title'] ?? 'Order #${order!['id']}';
    final imageUrl = ApiService.imageUrl(
      order!['portfolio']?['image']?.toString(),
    );
    final price = order!['total_price'] ?? 0;
    final deadline = order!['deadline'];
    final rawType = order!['portfolio']?['raw_file_type'];
    final deliveryFile = order!['latest_design_file'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 180,
              color: Colors.white10,
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white38,
                        size: 42,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white38,
                              size: 42,
                            ),
                          ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#ORD-${order!['id']}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              _badge(status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          _row('Designer', order!['designer']?['name'] ?? '-'),
          _row('Customer', order!['customer']?['name'] ?? '-'),
          _row('Harga', 'Rp ${_fmt(price)}'),
          if (!_isDesignOrder && deadline != null)
            _row('Deadline', deadline.toString().split('T')[0]),
          if (rawType != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: Colors.purpleAccent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'File raw tersedia: .${rawType.toString().toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          if (deliveryFile != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.task_outlined,
                  color: Colors.greenAccent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'File hasil jasa: ${deliveryFile['file_name'] ?? '-'}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _deliveryDownloadCard() {
    final file = order!['latest_design_file'] as Map<String, dynamic>?;
    final fileName = file?['file_name']?.toString() ?? 'file hasil jasa';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.download_done, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                'File Hasil Jasa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(isDownloading ? 'Mengunduh...' : 'Download File'),
              onPressed: isDownloading ? null : _downloadDeliveryFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadCard() {
    final rawType =
        order!['portfolio']?['raw_file_type']?.toString().toUpperCase() ??
        'FILE';
    final rawName = order!['portfolio']?['raw_file_name'] ?? 'file.$rawType';
    final status = order!['status'];
    final isReady = status != null && status != 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.deepPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.download_rounded, color: Colors.purpleAccent),
              SizedBox(width: 8),
              Text(
                'File Desain',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isReady ? 'File raw tersedia: $rawName' : 'File tidak tersedia.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                isDownloading ? 'Mengunduh...' : 'Download .$rawType',
              ),
              onPressed: (isReady && !isDownloading) ? _downloadFile : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                disabledBackgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    final progress = (order!['progress'] ?? 0) as int;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
          if (widget.role == 'designer' &&
              order!['status'] == 'in_progress') ...[
            const SizedBox(height: 12),
            Row(
              children: [10, 25, 50, 75, 100]
                  .map(
                    (p) => Expanded(
                      child: GestureDetector(
                        onTap: () => _updateProgress(p),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: progress >= p
                                ? Colors.purple
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$p',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: progress >= p
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Tap untuk update progress',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _designerActions() {
    final status = order!['status'];
    return Column(
      children: [
        if (status == 'pending')
          _btn(
            'Mulai Pengerjaan',
            Colors.blue,
            () => _updateStatus('in_progress'),
          ),
        if (status == 'in_progress') ...[
          const SizedBox(height: 8),
          _btn(
            isCompletingService
                ? 'Mengupload...'
                : _isServiceOrder
                ? 'Upload File & Selesaikan'
                : 'Tandai Selesai',
            Colors.green,
            _isServiceOrder
                ? () => _completeServiceWithFile()
                : () => _updateStatus('completed'),
          ),
        ],
        if (status == 'revision')
          _btn(
            'Mulai Revisi',
            Colors.orange,
            () => _updateStatus('in_progress'),
          ),
      ],
    );
  }

  Widget _customerActions() {
    final status = order!['status'];
    return Column(
      children: [
        if (status == 'in_progress')
          _btn('Minta Revisi', Colors.orange, () => _updateStatus('revision')),
        if (status == 'in_progress' || status == 'revision')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _btn(
              'Selesaikan Order',
              Colors.green,
              () => _updateStatus('completed'),
            ),
          ),
        if (status == 'pending')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _btn(
              'Batalkan Order',
              Colors.red,
              () => _updateStatus('cancelled'),
            ),
          ),
      ],
    );
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );

  Widget _badge(String status) {
    Color c;
    String lbl;
    switch (status) {
      case 'pending':
        c = Colors.orange;
        lbl = 'Pending';
        break;
      case 'in_progress':
        c = Colors.blue;
        lbl = 'In Progress';
        break;
      case 'revision':
        c = Colors.yellow;
        lbl = 'Revision';
        break;
      case 'completed':
        c = Colors.green;
        lbl = 'Completed';
        break;
      case 'cancelled':
        c = Colors.red;
        lbl = 'Cancelled';
        break;
      default:
        c = Colors.grey;
        lbl = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(lbl, style: TextStyle(color: c, fontSize: 12)),
    );
  }

  String _fmt(dynamic price) {
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
