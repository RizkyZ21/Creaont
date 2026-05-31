import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'explore_tab.dart';
import 'chat_tab.dart';
import 'orders_tab.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (currentIndex) {
      case 0:
        currentPage = const HomeTab();
        break;
      case 1:
        currentPage = const ExploreTab();
        break;
      case 2:
        currentPage = const ChatTab();
        break;
      case 3:
        currentPage = const OrdersTab();
        break;
      case 4:
        currentPage = const ProfileTab();
        break;
      default:
        currentPage = const Center(
          child: Text("Coming Soon", style: TextStyle(color: Colors.white)),
        );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(child: currentPage),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B3A),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.search, "Explore", 1),
            _navItem(Icons.chat_bubble_outline, "Chat", 2),
            _navItem(Icons.shopping_bag_outlined, "Orders", 3),
            _navItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isActive ? 20 : 0,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: Colors.purpleAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(icon, color: isActive ? Colors.purpleAccent : Colors.white54),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.purpleAccent : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
