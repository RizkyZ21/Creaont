import 'package:flutter/material.dart';

import '../../services/core/api_service.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../order/service_option_screen.dart';

class DesignerRecommendationScreen extends StatefulWidget {
  const DesignerRecommendationScreen({super.key});

  @override
  State<DesignerRecommendationScreen> createState() =>
      _DesignerRecommendationScreenState();
}

class _DesignerRecommendationScreenState
    extends State<DesignerRecommendationScreen> {
  final _budgetCtrl   = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _briefCtrl    = TextEditingController();

  bool _isLoading = false;
  List<String> _categories = const ['All'];
  String _selectedCategory = 'All';
  List<dynamic> _results = [];
  bool _hasSearched = false;

  static const _fallbackCategories = [
    'All', 'UI/UX', 'Logo', 'Illustration', 'Branding', 'Motion', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _deadlineCtrl.dispose();
    _briefCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final res = await PortfolioService.getCategories();
    if (!mounted) return;

    final loaded = res['success'] == true
        ? ((res['data'] as List?) ?? [])
              .map((item) => item is Map ? item['name']?.toString() : '$item')
              .whereType<String>()
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : <String>[];

    setState(() {
      _categories = [
        'All',
        ...(loaded.isNotEmpty ? loaded : _fallbackCategories.skip(1)),
      ];
    });
  }

  Future<void> _recommend() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final budgetText   = _budgetCtrl.text.replaceAll('.', '').trim();
    final deadlineText = _deadlineCtrl.text.trim();
    final res = await PortfolioService.getDesignerRecommendations(
      category:     _selectedCategory,
      budget:       double.tryParse(budgetText),
      deadlineDays: int.tryParse(deadlineText),
      brief:        _briefCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _results   = res['success'] == true ? (res['data'] as List? ?? []) : [];
    });

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Rekomendasi gagal dimuat'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
          'Sistem Pakar Designer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info metode sistem pakar ────────────────────────────
            _ExpertSystemInfo(),
            const SizedBox(height: 14),

            // ── Panel kriteria ──────────────────────────────────────
            _CriteriaPanel(
              categories:       _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
              budgetCtrl:   _budgetCtrl,
              deadlineCtrl: _deadlineCtrl,
              briefCtrl:    _briefCtrl,
              onSubmit:     _isLoading ? null : _recommend,
            ),
            const SizedBox(height: 18),

            // ── Hasil ───────────────────────────────────────────────
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.lightBlueAccent),
                ),
              )
            else if (!_hasSearched)
              const _EmptyRecommendation(searched: false)
            else if (_results.isEmpty)
              const _EmptyRecommendation(searched: true)
            else ...[
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.lightBlueAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Rekomendasi Terbaik (${_results.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._results.asMap().entries.map(
                (entry) => _RecommendationCard(
                  item:  entry.value,
                  rank:  entry.key + 1,
                  onTap: () => _openService(entry.value),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openService(dynamic recommendation) {
    final portfolio = recommendation['portfolio'] as Map<String, dynamic>;
    final designer  = recommendation['designer']  as Map<String, dynamic>?;
    final imageUrl  = ApiService.imageUrl(
      portfolio['image_url'] ?? portfolio['image'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceOptionScreen(
          portfolioId:   portfolio['id'],
          designerId:    portfolio['user_id'],
          title:         portfolio['title'] ?? '-',
          price:         'Rp ${_fmt(portfolio['price'])}',
          description:   portfolio['description'] ?? '',
          designerName:  designer?['name'] ?? 'Designer',
          imageUrl:      imageUrl,
          portfolioType: portfolio['type'] ?? 'service',
        ),
      ),
    );
  }

  String _fmt(dynamic price) {
    if (price == null) return '0';
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

// ── Info metode ────────────────────────────────────────────────────────
class _ExpertSystemInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const weights = [
      ('Kategori',    25, Colors.lightBlueAccent),
      ('Budget',      20, Colors.greenAccent),
      ('Rating',      20, Colors.amberAccent),
      ('Pengalaman',  15, Colors.orangeAccent),
      ('Deadline',    12, Colors.purpleAccent),
      ('Brief',        8, Colors.pinkAccent),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F3C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'Weighted Scoring + Rule-Based',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: weights.map((w) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: w.$3.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: w.$3.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${w.$1} ${w.$2}%',
                  style: TextStyle(color: w.$3, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Panel kriteria ─────────────────────────────────────────────────────
class _CriteriaPanel extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController budgetCtrl;
  final TextEditingController deadlineCtrl;
  final TextEditingController briefCtrl;
  final VoidCallback? onSubmit;

  const _CriteriaPanel({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.budgetCtrl,
    required this.deadlineCtrl,
    required this.briefCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F3C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_alt, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text(
                'Kriteria Kebutuhan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            dropdownColor: const Color(0xFF0D1F3C),
            decoration: _inputDecoration('Kategori Jasa'),
            style: const TextStyle(color: Colors.white),
            items: categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Budget maks (Rp)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: deadlineCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Deadline (hari)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: briefCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              'Deskripsikan kebutuhan desain Anda...',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Cari Rekomendasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white10,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

// ── Kartu rekomendasi ──────────────────────────────────────────────────
class _RecommendationCard extends StatefulWidget {
  final dynamic item;
  final int rank;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.item,
    required this.rank,
    required this.onTap,
  });

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  bool _showBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final portfolio = widget.item['portfolio'] as Map<String, dynamic>;
    final designer  = widget.item['designer']  as Map<String, dynamic>?;
    final metrics   = widget.item['metrics']   as Map<String, dynamic>? ?? {};
    final rules     = (widget.item['rules']    as List? ?? []).toList();
    final breakdown = widget.item['breakdown'] as Map<String, dynamic>?;
    final imageUrl  = ApiService.imageUrl(
      portfolio['image_url'] ?? portfolio['image'],
    );
    final score = widget.item['match_percentage'] as int? ?? 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F3C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0288D1).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _rankColor(widget.rank).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: _rankColor(widget.rank).withValues(alpha: 0.6)),
                    ),
                    child: Center(
                      child: Text(
                        '#${widget.rank}',
                        style: TextStyle(
                          color: _rankColor(widget.rank),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portfolio['title'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          designer?['name'] ?? 'Designer',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            if (metrics['rating'] != null) ...[
                              const Icon(Icons.star, color: Colors.amber, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '${metrics['rating']}',
                                style: const TextStyle(color: Colors.amber, fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                            ],
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '${metrics['orders_count'] ?? 0} order',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _ScoreBadge(score: score),
                ],
              ),
            ),

            // ── Skor bar visual ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 5,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Rules singkat ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: rules.take(3).map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$rule',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // ── Toggle breakdown skor ────────────────────────────
            if (breakdown != null) ...[
              GestureDetector(
                onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        _showBreakdown ? 'Sembunyikan detail skor' : 'Lihat detail skor',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showBreakdown ? Icons.expand_less : Icons.expand_more,
                        color: Colors.lightBlueAccent,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showBreakdown)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _BreakdownTable(breakdown: breakdown),
                ),
            ] else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return Colors.amberAccent;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return Colors.white38;
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.lightBlueAccent;
    if (score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Widget _placeholder() => Container(
    width: 58,
    height: 58,
    color: const Color(0xFF0288D1).withValues(alpha: 0.2),
    child: const Icon(Icons.design_services, color: Colors.lightBlueAccent),
  );
}

// ── Tabel breakdown skor ───────────────────────────────────────────────
class _BreakdownTable extends StatelessWidget {
  final Map<String, dynamic> breakdown;

  static const _labels = {
    'category':   ('Kategori',    Icons.category_outlined,    Colors.lightBlueAccent),
    'budget':     ('Budget',      Icons.account_balance_wallet_outlined, Colors.greenAccent),
    'rating':     ('Rating',      Icons.star_outline,         Colors.amberAccent),
    'experience': ('Pengalaman',  Icons.work_outline,         Colors.orangeAccent),
    'deadline':   ('Deadline',    Icons.schedule_outlined,    Colors.purpleAccent),
    'keyword':    ('Brief',       Icons.notes_outlined,       Colors.pinkAccent),
  };

  const _BreakdownTable({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: _labels.entries.map((entry) {
          final key   = entry.key;
          final meta  = entry.value;
          final data  = breakdown[key] as Map<String, dynamic>?;
          if (data == null) return const SizedBox.shrink();

          final got = (data['score'] as num?)?.toDouble() ?? 0;
          final max = (data['max']   as num?)?.toDouble() ?? 0;
          final pct = max > 0 ? got / max : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(meta.$2, color: meta.$3, size: 14),
                const SizedBox(width: 6),
                SizedBox(
                  width: 80,
                  child: Text(
                    meta.$1,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(meta.$3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 46,
                  child: Text(
                    '${got.toStringAsFixed(0)}/${max.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: meta.$3,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Score badge lingkaran ──────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  Color get _color {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.lightBlueAccent;
    if (score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withValues(alpha: 0.45)),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────
class _EmptyRecommendation extends StatelessWidget {
  final bool searched;
  const _EmptyRecommendation({required this.searched});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            searched ? Icons.search_off : Icons.manage_search,
            color: Colors.white38,
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            searched
                ? 'Tidak ada designer yang cocok dengan kriteria ini.\nCoba perluas budget atau ubah kategori.'
                : 'Isi kriteria di atas untuk mendapatkan rekomendasi designer terbaik.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
