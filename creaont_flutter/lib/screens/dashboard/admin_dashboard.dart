import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../services/core/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummary();
  }

  Future<Map<String, dynamic>> _fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse(ApiService.adminSummaryUrl),
      headers: ApiService.headers(token: token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message']?.toString() ?? 'Gagal memuat dashboard');
    }

    return body['data'] as Map<String, dynamic>;
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = _fetchSummary();
    });
    await _summaryFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF162033),
        foregroundColor: Colors.white,
        title: const Text('Creaont Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data ?? {};
          final stats = (data['stats'] as Map?) ?? {};
          final recentOrders = (data['recent_orders'] as List?) ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Ringkasan Operasional',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _StatsGrid(stats: stats),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Terbaru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${recentOrders.length} item',
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentOrders.isEmpty)
                  const _EmptyState()
                else
                  ...recentOrders.map((order) {
                    return _OrderTile(order: order as Map<String, dynamic>);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final Map stats;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900
        ? 4
        : width >= 620
        ? 3
        : 2;

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: width < 380 ? 1.15 : 1.35,
      children: [
        _StatCard(
          'Users',
          stats['total_users'],
          Icons.people_alt,
          const Color(0xFF38BDF8),
        ),
        _StatCard(
          'Designer',
          stats['total_designers'],
          Icons.brush,
          const Color(0xFFA78BFA),
        ),
        _StatCard(
          'Order',
          stats['total_orders'],
          Icons.shopping_bag,
          const Color(0xFFFBBF24),
        ),
        _StatCard(
          'Pending',
          stats['pending_orders'],
          Icons.pending_actions,
          const Color(0xFFFB7185),
        ),
        _StatCard(
          'Progress',
          stats['in_progress_orders'],
          Icons.timelapse,
          const Color(0xFF2DD4BF),
        ),
        _StatCard(
          'Selesai',
          stats['completed_orders'],
          Icons.check_circle,
          const Color(0xFF34D399),
        ),
        _StatCard(
          'Portfolio',
          stats['total_portfolios'],
          Icons.image,
          const Color(0xFF60A5FA),
        ),
        _StatCard(
          'Kategori',
          stats['total_categories'],
          Icons.category,
          const Color(0xFF22C55E),
        ),
        _StatCard(
          'Revenue',
          _currency(stats['total_revenue']),
          Icons.payments,
          const Color(0xFFF472B6),
        ),
      ],
    );
  }

  static String _currency(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '0') ?? 0;
    final text = number
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $text';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.title, this.value, this.icon, this.color);

  final String title;
  final dynamic value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF162033),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263247)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value?.toString() ?? '0',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final customer = order['customer'] as Map<String, dynamic>?;
    final designer = order['designer'] as Map<String, dynamic>?;
    final portfolio = order['portfolio'] as Map<String, dynamic>?;
    final imageUrl = ApiService.imageUrl(portfolio?['image_url']?.toString() ?? portfolio?['image']?.toString());
    final progress = order['progress'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF162033),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263247)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderPreview(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order['id']} - ${portfolio?['title'] ?? 'Order'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${customer?['name'] ?? 'Customer'} -> ${designer?['name'] ?? 'Designer'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(status: order['status']?.toString() ?? 'pending'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (double.tryParse(progress.toString()) ?? 0) / 100,
              backgroundColor: const Color(0xFF263247),
              color: const Color(0xFF34D399),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        height: 58,
        color: const Color(0xFF263247),
        child: imageUrl.isEmpty
            ? const Icon(Icons.image_not_supported, color: Color(0xFF94A3B8))
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'completed' => const Color(0xFF16A34A),
      'in_progress' => const Color(0xFF0284C7),
      'revision' => const Color(0xFF9333EA),
      'cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFFD97706),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Belum ada order',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFB7185), size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
