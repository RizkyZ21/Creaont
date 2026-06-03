import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import '../portfolio/portfolio_screen.dart';
import '../../services/core/api_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String role = 'customer';
  String name = 'User';
  String email = '-';
  String token = '';
  String avatar = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'customer';
      name = prefs.getString('name') ?? 'User';
      email = prefs.getString('email') ?? '-';
      token = prefs.getString('token') ?? '';
      avatar = prefs.getString('avatar') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // ── Dialog konfirmasi upgrade ke designer ─────────────────────────
  Future<void> _showUpgradeDialog() async {
    bool agreed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.brush, color: Colors.lightBlueAccent),
              SizedBox(width: 10),
              Text(
                'Daftar sebagai Designer',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poin-poin info
              _dialogPoint(
                Icons.check_circle_outline,
                Colors.green,
                'Kamu bisa menjual karya & jasa desain kepada pengguna lain.',
              ),
              const SizedBox(height: 10),
              _dialogPoint(
                Icons.shopping_bag_outlined,
                Colors.blue,
                'Kamu tetap bisa membeli desain dari designer lain seperti biasa.',
              ),
              const SizedBox(height: 10),
              _dialogPoint(
                Icons.warning_amber_rounded,
                Colors.orangeAccent,
                'Perubahan role ini PERMANEN dan tidak bisa dikembalikan ke Customer.',
              ),
              const SizedBox(height: 20),
              // Checkbox setuju
              GestureDetector(
                onTap: () => setDialogState(() => agreed = !agreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: agreed ? const Color(0xFF0288D1) : Colors.transparent,
                        border: Border.all(
                          color: agreed ? const Color(0xFF0288D1) : Colors.white54,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: agreed
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saya mengerti dan menyetujui ketentuan di atas.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: agreed
                  ? () {
                      Navigator.pop(ctx);
                      _doUpgrade();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                disabledBackgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doUpgrade() async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.upgradeToDesignerUrl),
        headers: ApiService.headers(token: token),
      );
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'designer');

        if (mounted) {
          setState(() => role = 'designer');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selamat! Akun kamu sekarang menjadi Designer 🎨'),
              backgroundColor: const Color(0xFF0288D1),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Gagal upgrade'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koneksi gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesigner = role == 'designer';
    final isAdmin = role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ── Avatar + info ────────────────────────────────────
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(ApiService.imageUrl(avatar))
                        : const NetworkImage('https://i.pravatar.cc/150'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ).then((_) => _loadUser()),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 8),

              // ── Role badge (ganti toggle) ──────────────────────
              _roleBadge(role),

              // ── Tombol daftar designer — hanya untuk customer ──
              if (!isDesigner && !isAdmin) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showUpgradeDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.lightBlueAccent.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.brush, color: Colors.lightBlueAccent, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Daftar sebagai Designer?',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ── Account settings ──────────────────────────────
              _sectionTitle('ACCOUNT SETTINGS'),
              _card([
                _item(
                  Icons.person,
                  'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    ).then((_) => _loadUser());
                  },
                ),
                if (isDesigner)
                  _item(
                    Icons.work,
                    'Portfolio Saya',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PortfolioScreen(),
                        ),
                      );
                    },
                  ),
              ]),

              const SizedBox(height: 30),

              // ── Logout ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _logout,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Role badge ──────────────────────────────────────────────────────
  Widget _roleBadge(String r) {
    Color color;
    IconData icon;
    String label;
    switch (r) {
      case 'designer':
        color = Colors.lightBlueAccent;
        icon = Icons.brush;
        label = 'Designer';
        break;
      case 'admin':
        color = Colors.orangeAccent;
        icon = Icons.admin_panel_settings;
        label = 'Admin';
        break;
      default:
        color = Colors.blueAccent;
        icon = Icons.person;
        label = 'Customer';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogPoint(IconData icon, Color color, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    ],
  );

  Widget _sectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: children),
  );

  Widget _item(IconData icon, String text, {VoidCallback? onTap}) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: Colors.white),
    title: Text(text, style: const TextStyle(color: Colors.white)),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      color: Colors.white54,
      size: 16,
    ),
  );
}
