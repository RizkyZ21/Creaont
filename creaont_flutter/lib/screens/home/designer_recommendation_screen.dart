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
  final _budgetCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _briefCtrl = TextEditingController();

  bool _isLoading = false;
  List<String> _categories = const ['All'];
  String _selectedCategory = 'All';
  List<dynamic> _results = [];

  static const _fallbackCategories = [
    'All',
    'UI/UX',
    'Logo',
    'Illustration',
    'Branding',
    'Motion',
    'Other',
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
    setState(() => _isLoading = true);

    final budgetText = _budgetCtrl.text.replaceAll('.', '').trim();
    final deadlineText = _deadlineCtrl.text.trim();
    final res = await PortfolioService.getDesignerRecommendations(
      category: _selectedCategory,
      budget: double.tryParse(budgetText),
      deadlineDays: int.tryParse(deadlineText),
      brief: _briefCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _results = res['success'] == true ? (res['data'] as List? ?? []) : [];
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
            _CriteriaPanel(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
              budgetCtrl: _budgetCtrl,
              deadlineCtrl: _deadlineCtrl,
              briefCtrl: _briefCtrl,
              onSubmit: _isLoading ? null : _recommend,
            ),
            const SizedBox(height: 18),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlueAccent,
                  ),
                ),
              )
            else if (_results.isEmpty)
              const _EmptyRecommendation()
            else ...[
              const Text(
                'Rekomendasi Terbaik',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ..._results.map(
                (item) => _RecommendationCard(
                  item: item,
                  onTap: () => _openService(item),
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
    final designer = recommendation['designer'] as Map<String, dynamic>?;
    final imageUrl = ApiService.imageUrl(
      portfolio['image_url'] ?? portfolio['image'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceOptionScreen(
          portfolioId: portfolio['id'],
          designerId: portfolio['user_id'],
          title: portfolio['title'] ?? '-',
          price: 'Rp ${_fmt(portfolio['price'])}',
          description: portfolio['description'] ?? '',
          designerName: designer?['name'] ?? 'Designer',
          imageUrl: imageUrl,
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
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            dropdownColor: const Color(0xFF0D1F3C),
            decoration: _inputDecoration('Kategori'),
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
                  decoration: _inputDecoration('Budget maks'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: deadlineCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Deadline hari'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: briefCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Brief singkat'),
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

class _RecommendationCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _RecommendationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final portfolio = item['portfolio'] as Map<String, dynamic>;
    final designer = item['designer'] as Map<String, dynamic>?;
    final metrics = item['metrics'] as Map<String, dynamic>? ?? {};
    final rules = (item['rules'] as List? ?? []).take(3).toList();
    final imageUrl = ApiService.imageUrl(
      portfolio['image_url'] ?? portfolio['image'],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
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
                      const SizedBox(height: 4),
                      Text(
                        designer?['name'] ?? 'Designer',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            metrics['rating']?.toString() ?? '-',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white38,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${metrics['orders_count'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _ScoreBadge(score: item['match_percentage'] ?? 0),
              ],
            ),
            const SizedBox(height: 10),
            ...rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.lightBlueAccent,
                      size: 14,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 64,
    height: 64,
    color: const Color(0xFF0288D1).withValues(alpha: 0.2),
    child: const Icon(Icons.design_services, color: Colors.lightBlueAccent),
  );
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.lightBlueAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EmptyRecommendation extends StatelessWidget {
  const _EmptyRecommendation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.manage_search, color: Colors.white38, size: 44),
          SizedBox(height: 10),
          Text(
            'Isi kriteria untuk mendapatkan rekomendasi designer.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
