import 'package:flutter/material.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';
import '../order/service_option_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  List<dynamic> portfolios = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  List<String> categories = const ['All'];
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
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await PortfolioService.getServices(
      category: selectedCategory,
      search: _searchCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        isLoading = false;
        portfolios = res['success'] == true ? (res['data'] as List) : [];
      });
    }
  }

  Future<void> _init() async {
    await _loadCategories();
    await _load();
  }

  Future<void> _loadCategories() async {
    final res = await PortfolioService.getCategories();
    if (!mounted) return;

    final loaded = res['success'] == true
        ? ((res['data'] as List?) ?? [])
              .map(
                (item) =>
                    item is Map ? item['name']?.toString() : item.toString(),
              )
              .whereType<String>()
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : <String>[];

    setState(() {
      categories = [
        'All',
        ...(loaded.isNotEmpty ? loaded : _fallbackCategories.skip(1)),
      ];
      if (!categories.contains(selectedCategory)) selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0C29),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari jasa desainer atau kategori...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _searchCtrl.clear();
                            _load();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),

            // Category chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final active = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = cat);
                      _load();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                              )
                            : null,
                        color: active ? null : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.purpleAccent,
                      ),
                    )
                  : portfolios.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada hasil',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: portfolios.length,
                        itemBuilder: (_, i) => _PortfolioCard(
                          item: portfolios[i],
                          onTap: () {
                            final item = portfolios[i];
                            final imageUrl = ApiService.imageUrl(item['image_url'] ?? item['image']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceOptionScreen(
                                  portfolioId: item['id'],
                                  designerId: item['user_id'],
                                  title: item['title'],
                                  price: 'Rp ${_fmt(item['price'])}',
                                  description: item['description'] ?? '',
                                  designerName:
                                      item['user']?['name'] ?? 'Designer',
                                  imageUrl: imageUrl,
                                  portfolioType: item['type'] ?? 'service',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
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

class _PortfolioCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _PortfolioCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.imageUrl(item['image_url'] ?? item['image']);
    final price = item['price'];
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    final priceStr = p
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['user']?['name'] ?? '-',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mulai Rp $priceStr',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.purple.withValues(alpha: 0.2),
    child: const Center(
      child: Icon(Icons.design_services, color: Colors.purple, size: 40),
    ),
  );
}
