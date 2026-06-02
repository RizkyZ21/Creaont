import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/core/api_service.dart';
import 'upload_design_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<dynamic> portfolios = [];
  bool isLoading = true;
  String token = '';

  @override
  void initState() {
    super.initState();
    _init();
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
        portfolios = res['success'] == true ? (res['data'] as List) : [];
      });
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B3A),
        title: const Text('Hapus Portfolio', style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin menghapus portfolio ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await PortfolioService.deletePortfolio(token: token, id: id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Deleted'), backgroundColor: Colors.purple),
      );
      if (res['success'] == true) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: const Text('Portfolio Saya', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => UploadDesignScreen(token: token)),
          );
          if (added == true) _load();
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : portfolios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.collections, color: Colors.white24, size: 64),
                      const SizedBox(height: 12),
                      const Text('Belum ada portfolio', style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 8),
                      const Text('Tap tombol + untuk menambahkan', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: portfolios.length,
                    itemBuilder: (_, i) {
                      final item = portfolios[i];
                      final imageUrl = ApiService.imageUrl(item['image']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B3A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _placeholder())
                                  : _placeholder(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'] ?? '-',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item['category'] ?? '-',
                                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text('Rp ${_fmt(item['price'])}',
                                        style: const TextStyle(color: Colors.purpleAccent, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _delete(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _placeholder() => Container(
    width: 80, height: 80,
    color: Colors.purple.withValues(alpha: 0.2),
    child: const Icon(Icons.design_services, color: Colors.purple),
  );

  String _fmt(dynamic price) {
    if (price == null) return '0';
    final num p = price is num ? price : double.tryParse(price.toString()) ?? 0;
    return p.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
