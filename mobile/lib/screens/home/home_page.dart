import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    // 🔥 SAFE SWITCH (ANTI CRASH)
    switch (currentIndex) {
      case 0:
        currentPage = const HomeTab();
        break;
      case 1:
        currentPage = const ProfileTab();
        break;
      default:
        currentPage = const Center(
          child: Text("ERROR PAGE", style: TextStyle(color: Colors.white)),
        );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: currentPage),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
