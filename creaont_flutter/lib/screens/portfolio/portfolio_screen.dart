import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';
import 'upload_design_screen.dart';
import 'portfolio_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> allPortfolios = [];
  bool isLoading = true;
  String token = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    await _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await PortfolioService.getMyPortfolios(token: token);
    if (mounted) {
      setState(() {
        isLoading = false;
        allPortfolios =
            res['success'] == true ? (res['data'] as List) : [];
      });
    }
  }

  List<dynamic> get _karya =>
      allPortfolios.where((p) => p['type'] == 'design').toList();
  List<dynamic> get _jasa =>
      allPortfolios.where((p) => p['type'] == 'service').toList();

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        title: const Text(
          'Hapus Portfolio',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Yakin ingin menghapus portfolio ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await PortfolioService.deletePortfolio(token: token, id: id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Deleted'),
          backgroundColor: const Color(0xFF0288D1),
        ),
      );
      if (res['success'] == true) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text(
          'Portfolio Saya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightBlueAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 16),
                  const SizedBox(width: 6),
                  const Text('Porto Karya'),
                  if (!isLoading && _karya.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _badge(_karya.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.design_services_outlined, size: 16),
                  const SizedBox(width: 6),
                  const Text('Jasa'),
                  if (!isLoading && _jasa.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _badge(_jasa.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0288D1),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => UploadDesignScreen(token: token),
            ),
          );
          if (added == true) _load();
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _PortfolioList(
                  items: _karya,
                  emptyIcon: Icons.photo_library_outlined,
                  emptyMsg: 'Belum ada karya jadi',
                  emptyHint: 'Tap + untuk unggah desain jadi',
                  onDelete: _delete,
                  onRefresh: _load,
                  token: token,
                ),
                _PortfolioList(
                  items: _jasa,
                  emptyIcon: Icons.design_services_outlined,
                  emptyMsg: 'Belum ada listing jasa',
                  emptyHint: 'Tap + untuk tambah jasa desain',
                  onDelete: _delete,
                  onRefresh: _load,
                  token: token,
                ),
              ],
            ),
    );
  }

  Widget _badge(int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ── Reusable list widget per tab ─────────────────────────────────────
class _PortfolioList extends StatelessWidget {
  final List<dynamic> items;
  final IconData emptyIcon;
  final String emptyMsg;
  final String emptyHint;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function() onRefresh;
  final String token;

  const _PortfolioList({
    required this.items,
    required this.emptyIcon,
    required this.emptyMsg,
    required this.emptyHint,
    required this.onDelete,
    required this.onRefresh,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, color: Colors.white24, size: 64),
            const SizedBox(height: 12),
            Text(emptyMsg, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Text(
              emptyHint,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final imageUrl = ApiService.imageUrl(item['image_url'] ?? item['image']);
          final isService = item['type'] == 'service';
          final avgRating = item['reviews_avg_rating'];
          final ordersCount = item['orders_count'] ?? 0;

          return GestureDetector(
            onTap: () async {
              final updated = await Navigator.push<bool>(
                ctx,
                MaterialPageRoute(
                  builder: (_) => PortfolioDetailScreen(
                    portfolio: Map<String, dynamic>.from(item),
                    token: token,
                  ),
                ),
              );
              if (updated == true) onRefresh();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F3C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, __) =>
                              _placeholder(isService),
                        )
                      : _placeholder(isService),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isService
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isService ? 'Jasa' : 'Karya',
                                style: TextStyle(
                                  color: isService
                                      ? Colors.blueAccent
                                      : Colors.greenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['category'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${_fmt(item['price'])}',
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white38,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$ordersCount terjual',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            if (avgRating != null) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                double.tryParse(avgRating.toString())
                                        ?.toStringAsFixed(1) ??
                                    '-',
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
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onDelete(item['id']),
                ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(bool isService) => Container(
        width: 88,
        height: 88,
        color: const Color(0xFF0288D1).withValues(alpha: 0.2),
        child: Icon(
          isService ? Icons.design_services : Icons.photo,
          color: const Color(0xFF0288D1),
        ),
      );

  String _fmt(dynamic price) {
    if (price == null) return '0';
    final num p =
        price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
