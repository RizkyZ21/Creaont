import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';
import '../order/service_option_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String name = 'User';
  String selectedCat = 'All';
  List<dynamic> popular = [];
  List<String> categories = const ['All'];
  bool isLoading = true;

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

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => name = prefs.getString('name') ?? 'User');
    await _loadCategories();
    await _loadPopular();
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
      if (!categories.contains(selectedCat)) selectedCat = 'All';
    });
  }

  Future<void> _loadPopular() async {
    setState(() => isLoading = true);
    final res = await PortfolioService.getPopularPortfolios(
      category: selectedCat,
      limit: 10,
    );
    if (mounted) {
      setState(() {
        isLoading = false;
        popular = res['success'] == true ? (res['data'] as List) : [];
      });
    }
  }

  void _selectCategory(String cat) {
    if (selectedCat == cat) return;
    setState(() => selectedCat = cat);
    _loadPopular();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPopular,
          color: Colors.purpleAccent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Banner / Search hint ─────────────────────────────
              SliverToBoxAdapter(child: _buildSearchHint()),

              // ── Category chips ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedCat != 'All')
                        GestureDetector(
                          onTap: () => _selectCategory('All'),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildCategoryChips()),

              // ── Popular section title ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedCat == 'All'
                            ? 'Paling Populer'
                            : 'Populer — $selectedCat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Popular list ─────────────────────────────────────
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                )
              else if (popular.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: Colors.white24,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedCat == 'All'
                                ? 'Belum ada portfolio tersedia'
                                : 'Belum ada portfolio di kategori "$selectedCat"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PopularCard(
                      item: popular[i],
                      rank: i + 1,
                      onTap: () {
                        final item = popular[i];
                        final imageUrl = ApiService.imageUrl(item['image']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceOptionScreen(
                              portfolioId: item['id'],
                              designerId: item['user_id'],
                              title: item['title'],
                              price: 'Rp ${_fmt(item['price'])}',
                              description: item['description'] ?? '',
                              designerName: item['user']?['name'] ?? 'Designer',
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    childCount: popular.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.white38),
            SizedBox(width: 10),
            Text(
              'Cari desainer atau karya...',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final icon = _categoryIcon(cat);
          final active = selectedCat == cat;
          return GestureDetector(
            onTap: () => _selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                      )
                    : null,
                color: active ? null : Colors.white10,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: active ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white54,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'all' => Icons.apps,
      'ui/ux' => Icons.design_services,
      'logo' => Icons.brush,
      'illustration' => Icons.palette,
      'branding' => Icons.campaign,
      'motion' => Icons.movie_filter,
      _ => Icons.category,
    };
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

// ── Popular Card ─────────────────────────────────────────────────────

class _PopularCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int rank;
  final VoidCallback onTap;

  const _PopularCard({
    required this.item,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.imageUrl(item['image']);
    final designerName = item['user']?['name'] ?? 'Designer';
    final ordersCount = item['orders_count'] ?? 0;
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B3A),
          borderRadius: BorderRadius.circular(18),
          border: rank <= 3
              ? Border.all(
                  color: _rankColor(rank).withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _rankColor(rank).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rank <= 3
                    ? Icon(_rankIcon(rank), color: _rankColor(rank), size: 18)
                    : Text(
                        '$rank',
                        style: TextStyle(
                          color: _rankColor(rank),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.white38,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          designerName,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rp $priceStr',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (ordersCount > 0) ...[
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white38,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$ordersCount terjual',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.design_services, color: Colors.white, size: 24),
  );

  Color _rankColor(int r) {
    if (r == 1) return const Color(0xFFFFD700); // gold
    if (r == 2) return const Color(0xFFC0C0C0); // silver
    if (r == 3) return const Color(0xFFCD7F32); // bronze
    return Colors.white38;
  }

  IconData _rankIcon(int r) {
    if (r == 1) return Icons.emoji_events;
    if (r == 2) return Icons.workspace_premium;
    return Icons.military_tech;
  }
}
