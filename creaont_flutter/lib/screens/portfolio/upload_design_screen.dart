import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/portfolio/portfolio_service.dart';

class UploadDesignScreen extends StatefulWidget {
  final String token;
  const UploadDesignScreen({super.key, required this.token});

  @override
  State<UploadDesignScreen> createState() => _UploadDesignScreenState();
}

class _UploadDesignScreenState extends State<UploadDesignScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = 'UI/UX';
  bool _loading    = false;

  // Thumbnail
  XFile?      _imageXFile;
  Uint8List?  _imageBytes;   // untuk preview di web

  // Raw file
  PlatformFile? _rawFile;

  final categories = ['UI/UX', 'Logo', 'Illustration', 'Branding', 'Motion', 'Other'];

  // ── Pick thumbnail dari galeri ─────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageXFile  = picked;
      _imageBytes  = bytes;
    });
  }

  // ── Pick file raw (cdr, psd, ai, pdf, dll) ─────────────────────────
  // Pakai FileType.any karena ekstensi desain (.cdr, .ai, .fig, dll)
  // tidak dikenali MIME browser — FileType.custom akan diblokir.
  static const _allowedExt = [
    'pdf','zip','ai','psd','cdr','fig','sketch','xd',
    'svg','eps','indd','afdesign','afphoto','rar','7z',
  ];

  Future<void> _pickRawFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,       // wajib true agar bytes tersedia di web
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext  = (file.extension ?? '').toLowerCase();

    // Validasi ekstensi manual
    if (!_allowedExt.contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Format tidak didukung: .$ext\n'
            'Gunakan: ${_allowedExt.join(', ')}',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ));
      }
      return;
    }

    // Pastikan bytes berhasil diload
    if (file.bytes == null || file.bytes!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal membaca file, coba lagi'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    setState(() => _rawFile = file);
  }

  // ── Submit ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty  ||
        _priceCtrl.text.trim().isEmpty) {
      _snack('Lengkapi semua field', Colors.orange);
      return;
    }
    if (_imageXFile == null) {
      _snack('Thumbnail gambar wajib diunggah', Colors.orange);
      return;
    }
    if (_rawFile == null) {
      _snack('File raw (desain asli) wajib diunggah', Colors.orange);
      return;
    }
    if (_rawFile!.bytes == null || _rawFile!.bytes!.isEmpty) {
      _snack('File raw gagal dibaca, pilih ulang file', Colors.orange);
      return;
    }
    final price = double.tryParse(_priceCtrl.text.replaceAll('.', '').replaceAll(',', '.'));
    if (price == null || price <= 0) {
      _snack('Harga tidak valid', Colors.orange);
      return;
    }

    setState(() => _loading = true);

    final res = await PortfolioService.createPortfolio(
      token:       widget.token,
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category:    _category,
      price:       price,
      imageXFile:  _imageXFile!,
      rawFile:     _rawFile!,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      _snack('Portfolio berhasil diunggah!', Colors.green);
      Navigator.pop(context, true);
    } else {
      _snack(res['message'] ?? 'Upload gagal', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: const Text('Upload Portfolio', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Thumbnail (wajib) ──────────────────────────────────
            _sectionLabel('Thumbnail / Preview Karya', required: true),
            const SizedBox(height: 4),
            const Text(
              'Gambar yang ditampilkan ke publik. Boleh diberi watermark.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageBytes != null
                        ? Colors.green.withValues(alpha: 0.6)
                        : Colors.purple.withValues(alpha: 0.5),
                  ),
                ),
                child: _imageBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate, color: Colors.purple, size: 48),
                          SizedBox(height: 8),
                          Text('Tap untuk pilih gambar', style: TextStyle(color: Colors.white54)),
                          SizedBox(height: 4),
                          Text('JPG / PNG / WEBP • Maks 4MB', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() { _imageXFile = null; _imageBytes = null; }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8, right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)),
                              child: const Row(children: [
                                Icon(Icons.check, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text('Dipilih', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ]),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ── File Raw (wajib) ───────────────────────────────────
            _sectionLabel('File Desain Asli (Raw)', required: true),
            const SizedBox(height: 4),
            const Text(
              'File ini hanya bisa didownload oleh pembeli. (.cdr .psd .ai .fig .pdf .zip dll)',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickRawFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _rawFile != null
                        ? Colors.green.withValues(alpha: 0.6)
                        : Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: _rawFile == null
                    ? Row(children: const [
                        Icon(Icons.upload_file, color: Colors.orange, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Upload File Raw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text('Tap untuk pilih file desain asli', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white38),
                      ])
                    : Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.insert_drive_file, color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _rawFile!.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatSize(_rawFile!.size),
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _rawFile = null),
                          child: const Icon(Icons.close, color: Colors.white38, size: 20),
                        ),
                      ]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Info box ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thumbnail akan dilihat semua orang. File raw hanya bisa didownload setelah pembeli menyelesaikan order.',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Judul ──────────────────────────────────────────────
            _sectionLabel('Judul Karya', required: true),
            _field(_titleCtrl, 'Contoh: Logo Modern Minimalist'),
            const SizedBox(height: 16),

            // ── Deskripsi ──────────────────────────────────────────
            _sectionLabel('Deskripsi', required: true),
            _field(_descCtrl, 'Jelaskan karya ini secara detail...', maxLines: 4),
            const SizedBox(height: 16),

            // ── Kategori ───────────────────────────────────────────
            _sectionLabel('Kategori', required: true),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1B3A),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(height: 16),

            // ── Harga ──────────────────────────────────────────────
            _sectionLabel('Harga (Rp)', required: true),
            _field(_priceCtrl, 'Contoh: 250000', keyboardType: TextInputType.number),
            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  disabledBackgroundColor: Colors.purple.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Upload Portfolio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      if (required) const Text(' *', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  String _formatSize(int bytes) {
    if (bytes < 1024)        return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
