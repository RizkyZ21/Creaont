import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String role = "customer";
  String name = "User";
  String email = "-"; // 🔥 TAMBAH
  String bio = "-"; // 🔥 TAMBAH

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "customer";
      name = prefs.getString('name') ?? "User";
      email = prefs.getString('email') ?? "-"; // 🔥 TAMBAH
      bio = prefs.getString('bio') ?? "-"; // 🔥 TAMBAH
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = role == "customer";

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🔥 PROFILE
              Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150",
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔥 NAME
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 🔥 EMAIL (NEW)
                  Text(email, style: const TextStyle(color: Colors.white54)),

                  const SizedBox(height: 4),

                  // 🔥 ROLE
                  Text(
                    isCustomer ? "Customer" : "Designer",
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 6),

                  // 🔥 BIO (NEW)
                  Text(
                    bio,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 🔥 ROLE SWITCH
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _roleButton("Customer", isCustomer),
                        _roleButton("Designer", !isCustomer),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔥 ACCOUNT SETTINGS
              _sectionTitle("ACCOUNT SETTINGS"),
              _card([
                _item(
                  Icons.person,
                  "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    ).then((_) => loadUser()); // 🔥 REFRESH
                  },
                ),
                _item(Icons.credit_card, "Payment Methods"),
                _item(Icons.security, "Security & Privacy"),
              ]),

              const SizedBox(height: 20),

              // 🔥 ACTIVITY
              _sectionTitle("ACTIVITY"),
              _card([
                _item(Icons.history, "Transaction History"),
                if (!isCustomer) _item(Icons.work, "My Services"),
                _item(Icons.help_outline, "Help & Support"),
              ]),

              const SizedBox(height: 30),

              // 🔥 LOGOUT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => logout(context),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _item(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
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
}
