import 'package:flutter/material.dart';

import '../order/order_detail_screen.dart';
import '../order/revision_screen.dart';
import '../order/history_transaction_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int selectedTab = 0;

  final List<String> tabs = ["Active", "Completed", "Cancelled"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Orders",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _circleIcon(Icons.filter_alt_outlined),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isActive = selectedTab == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },

                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),

                      child: Column(
                        children: [
                          Text(
                            tabs[index],

                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white54,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),

                            height: 3,

                            width: isActive ? 30 : 0,

                            decoration: BoxDecoration(
                              color: Colors.purpleAccent,

                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  if (selectedTab == 0) _orderCard(),

                  if (selectedTab == 1)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const HistoryTransactionScreen(),
                          ),
                        );
                      },

                      child: _emptyState("Open Transaction History"),
                    ),

                  if (selectedTab == 2) _emptyState("No cancelled orders"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "#ORD-8921 • 12 Oct 2023",

                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,

                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  "In Progress",

                  style: TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: Image.network(
                  "https://picsum.photos/80",

                  width: 60,

                  height: 60,

                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Mobile App UI/UX Design",

                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "by Alex Designer",

                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _progress(),

          const SizedBox(height: 20),

          Row(
            children: [
              _btnOutline("View Details", () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const OrderDetailScreen()),
                );
              }),

              const SizedBox(width: 10),

              _btnOutline("Revision", () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const RevisionScreen()),
                );
              }),

              const SizedBox(width: 10),

              _btnGradient("Complete", () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const HistoryTransactionScreen(),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnOutline(String text, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _btnGradient(String text, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _progress() {
    return const SizedBox();
  }

  Widget _emptyState(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.white54)),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: const BoxDecoration(
        color: Color(0xFF1E1B3A),

        shape: BoxShape.circle,
      ),

      child: Icon(icon, color: Colors.white),
    );
  }
}
