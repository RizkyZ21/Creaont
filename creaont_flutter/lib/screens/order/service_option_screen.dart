import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_order_screen.dart';

class ServiceOptionScreen extends StatefulWidget {
  final int portfolioId;
  final int designerId;
  final String title;
  final String price;
  final String description;
  final String designerName;
  final String imageUrl;
  final String portfolioType;

  const ServiceOptionScreen({
    super.key,
    required this.portfolioId,
    required this.designerId,
    required this.title,
    required this.price,
    required this.description,
    required this.designerName,
    required this.imageUrl,
    this.portfolioType = 'design',
  });

  @override
  State<ServiceOptionScreen> createState() => _ServiceOptionScreenState();
}

class _ServiceOptionScreenState extends State<ServiceOptionScreen> {
  String token = '';
  int myUserId = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() {
        token = p.getString('token') ?? '';
        myUserId = p.getInt('user_id') ?? 0;
      });
    });
  }

  bool get _isOwnPortfolio => myUserId != 0 && myUserId == widget.designerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.portfolioType == 'service' ? 'Detail Jasa' : 'Detail Karya',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      headers: const {'Accept': 'image/*'},
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                          'Thumbnail error: $error | url: ${widget.imageUrl}',
                        );
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.price,
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'by ${widget.designerName}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            if (widget.description.isNotEmpty) ...[
              const Text(
                'Deskripsi',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.description,
                  style: const TextStyle(color: Colors.white, height: 1.6),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // CTA
            if (_isOwnPortfolio)
              _infoBox(
                icon: Icons.info_outline,
                color: Colors.blueAccent,
                text: 'Ini adalah karya milik Anda sendiri.',
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    widget.portfolioType == 'service'
                        ? 'Sewa Jasa'
                        : 'Pesan Sekarang',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: token.isEmpty
                      ? () => _showLoginRequired(context)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateOrderScreen(
                              title: widget.title,
                              price: widget.price,
                              portfolioId: widget.portfolioId,
                              portfolioType: widget.portfolioType,
                              token: token,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              _infoBox(
                icon: Icons.shield_outlined,
                color: Colors.green,
                text: widget.portfolioType == 'service'
                    ? 'Pembayaran aman. Brief jasa akan diteruskan ke designer.'
                    : 'Pembayaran aman. File bisa didownload setelah pembayaran berhasil.',
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 220,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFFE100FF)]),
    ),
    child: const Icon(Icons.design_services, color: Colors.white, size: 80),
  );

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String text,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    ),
  );

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Silakan login terlebih dahulu untuk memesan'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
