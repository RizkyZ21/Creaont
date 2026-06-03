import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/review/review_service.dart';
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

  // Reviews state
  bool _reviewsLoading = true;
  List<dynamic> _reviews = [];
  double? _avgRating;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() {
        token = p.getString('token') ?? '';
        myUserId = p.getInt('user_id') ?? 0;
      });
    });
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _reviewsLoading = true);
    final res = await ReviewService.getByPortfolio(widget.portfolioId);
    if (mounted) {
      setState(() {
        _reviewsLoading = false;
        if (res['success'] == true) {
          _reviews = (res['data'] as List?) ?? [];
          final avg = res['avg_rating'];
          _avgRating = avg != null ? double.tryParse(avg.toString()) : null;
          _totalReviews = res['total'] ?? _reviews.length;
        }
      });
    }
  }

  bool get _isOwnPortfolio =>
      myUserId != 0 && myUserId == widget.designerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
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
            // ── Cover image ───────────────────────────────────────
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
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 20),

            // ── Title & price ─────────────────────────────────────
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
                color: Colors.lightBlueAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text(
                  'by ${widget.designerName}',
                  style: const TextStyle(color: Colors.white54),
                ),
                // Rating summary inline
                if (_avgRating != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${_avgRating!.toStringAsFixed(1)} ($_totalReviews ulasan)',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ── Description ───────────────────────────────────────
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

            // ── CTA ───────────────────────────────────────────────
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
                    backgroundColor: const Color(0xFF0288D1),
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

            const SizedBox(height: 32),
            // ── Rating & Ulasan ───────────────────────────────────
            _ReviewsSection(
              reviews: _reviews,
              avgRating: _avgRating,
              totalReviews: _totalReviews,
              isLoading: _reviewsLoading,
            ),
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
          gradient: LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
          ),
        ),
        child: const Icon(Icons.design_services, color: Colors.white, size: 80),
      );

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String text,
  }) =>
      Container(
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
            Expanded(child: Text(text, style: TextStyle(color: color))),
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

// ── Reviews section widget ────────────────────────────────────────────
class _ReviewsSection extends StatelessWidget {
  final List<dynamic> reviews;
  final double? avgRating;
  final int totalReviews;
  final bool isLoading;

  const _ReviewsSection({
    required this.reviews,
    required this.avgRating,
    required this.totalReviews,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            const Text(
              'Rating & Ulasan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (totalReviews > 0)
              Text(
                '$totalReviews ulasan',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            ),
          )
        else if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.white24, size: 40),
                SizedBox(height: 8),
                Text(
                  'Belum ada ulasan',
                  style: TextStyle(color: Colors.white54),
                ),
                SizedBox(height: 4),
                Text(
                  'Jadilah yang pertama memberikan ulasan',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          )
        else ...[
          // Rating summary bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      avgRating?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _StarRow(rating: avgRating ?? 0, size: 16),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews ulasan',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(child: _RatingBars(reviews: reviews)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Review cards
          ...reviews.map((r) => _ReviewCard(review: r)).toList(),
        ],
      ],
    );
  }
}

class _RatingBars extends StatelessWidget {
  final List<dynamic> reviews;
  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = List.filled(5, 0);
    for (final r in reviews) {
      final star = (r['rating'] as num?)?.toInt() ?? 0;
      if (star >= 1 && star <= 5) counts[star - 1]++;
    }
    final total = reviews.length;

    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = counts[star - 1];
        final ratio = total > 0 ? count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$star',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 11),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 18,
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final name = review['customer']?['name'] ?? 'Pengguna';
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment']?.toString() ?? '';
    final date = review['created_at']?.toString() ?? '';
    final dateShort = date.length >= 10 ? date.substring(0, 10) : date;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F3C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0288D1).withValues(alpha: 0.3),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    _StarRow(rating: rating.toDouble(), size: 13),
                  ],
                ),
              ),
              Text(
                dateShort,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.round();
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
