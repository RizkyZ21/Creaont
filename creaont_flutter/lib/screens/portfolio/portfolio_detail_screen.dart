import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final Map<String, dynamic> portfolio;
  final String token;

  const PortfolioDetailScreen({
    super.key,
    required this.portfolio,
    required this.token,
  });

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  XFile?     _newImageXFile;
  Uint8List? _newImageBytes;

  bool _isSaving = false;
  bool _isDirty  = false;

  @override
  void initState() {
    super.initState();
    _descCtrl  = TextEditingController(text: widget.portfolio['description'] ?? '');
    _priceCtrl = TextEditingController(
        text: _rawPrice(widget.portfolio['price']).toStringAsFixed(0));
    _descCtrl.addListener(_onChanged);
    _priceCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() => _isDirty = true);

  @override
  void dispose() {
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double _rawPrice(dynamic p) {
    if (p == null) return 0;
    return p is num ? p.toDouble() : double.tryParse(p.toString()) ?? 0;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _newImageXFile = picked;
      _newImageBytes = bytes;
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    final desc  = _descCtrl.text.trim();
    final price = double.tryParse(
        _priceCtrl.text.replaceAll('.', '').replaceAll(',', '.'));

    if (desc.isEmpty) {
      _snack('Deskripsi tidak boleh kosong', Colors.orange);
      return;
    }
    if (price == null || price <= 0) {
      _snack('Harga tidak valid', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    final res = await PortfolioService.updatePortfolio(
      token:       widget.token,
      id:          widget.portfolio['id'] as int,
      description: desc,
      price:       price,
      imageXFile:  _newImageXFile,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      _snack('Portfolio berhasil diperbarui!', Colors.green);
      setState(() {
        _isDirty       = false;
        _newImageXFile = null;
        _newImageBytes = null;
      });
      Navigator.pop(context, true);
    } else {
      final errors = res['errors'];
      String msg = res['message'] ?? 'Gagal menyimpan';
      if (errors is Map) {
        msg += '\n' +
            errors.values
                .map((v) => v is List ? v.first.toString() : v.toString())
                .join('\n');
      }
      _snack(msg, Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final p         = widget.portfolio;
    final isService = p['type'] == 'service';
    final title     = p['title'] ?? 'Portfolio';
    final category  = p['category'] ?? '-';
    final rawType   = p['raw_file_type'];
    final imageUrl  = ApiService.imageUrl(p['image_url'] ?? p['image']);
    final avgRating = p['reviews_avg_rating'];
    final soldCount = p['orders_count'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis),
        actions: [
          if (_isDirty)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.lightBlueAccent, strokeWidth: 2))
                  : const Text('Simpan',
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail (tap untuk ganti) ────────────────────────
            _sectionLabel('Thumbnail', editable: true),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildThumbnail(imageUrl),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera_outlined,
                                color: Colors.white, size: 30),
                            SizedBox(height: 6),
                            Text('Tap untuk ganti',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_newImageBytes != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.check, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('Gambar baru',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text('Tap thumbnail untuk menggantinya',
                style: TextStyle(color: Colors.white38, fontSize: 11)),

            const SizedBox(height: 20),

            // ── Info read-only ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F3C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: [
                _infoRow('Judul', title),
                _infoRow('Kategori', category),
                _infoRow('Jenis', isService ? 'Jasa' : 'Karya Jadi'),
                _infoRow('Terjual', '$soldCount kali'),
                if (avgRating != null)
                  _infoRow('Rating',
                      '⭐ ${double.tryParse(avgRating.toString())?.toStringAsFixed(1) ?? '-'}'),
                if (!isService && rawType != null)
                  _infoRow(
                      'File Raw', '.${rawType.toString().toUpperCase()}'),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Harga (editable) ───────────────────────────────────
            _sectionLabel('Harga (Rp)', editable: true),
            const SizedBox(height: 8),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                    color: Colors.lightBlueAccent, fontSize: 18),
                filled: true,
                fillColor: const Color(0xFF0D1F3C),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.lightBlueAccent)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Deskripsi (editable) ───────────────────────────────
            _sectionLabel('Deskripsi', editable: true),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Jelaskan portfolio ini secara detail...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0D1F3C),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.lightBlueAccent)),
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol Simpan ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                onPressed: (_isSaving || !_isDirty) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  disabledBackgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _buildThumbnail(String imageUrl) {
    if (_newImageBytes != null) {
      return Image.memory(_newImageBytes!,
          width: double.infinity, height: 220, fit: BoxFit.cover);
    }
    if (imageUrl.isNotEmpty) {
      return Image.network(imageUrl,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbPlaceholder());
    }
    return _thumbPlaceholder();
  }

  Widget _thumbPlaceholder() => Container(
        width: double.infinity,
        height: 220,
        color: const Color(0xFF0288D1).withValues(alpha: 0.15),
        child: const Icon(Icons.photo, color: const Color(0xFF0288D1), size: 64),
      );

  Widget _sectionLabel(String text, {bool editable = false}) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          if (editable) ...const [
            SizedBox(width: 6),
            Icon(Icons.edit_outlined,
                color: Colors.lightBlueAccent, size: 14),
          ],
        ],
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      );
}
