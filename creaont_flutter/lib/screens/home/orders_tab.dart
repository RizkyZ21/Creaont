import 'package:flutter/material.dart';

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
            // 🔥 HEADER
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

            // 🔥 TABS
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

            // 🔥 CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (selectedTab == 0) _orderCard(),
                  if (selectedTab == 1) _emptyState("No completed orders yet"),
                  if (selectedTab == 2) _emptyState("No cancelled orders"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CARD ORDER
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
          // 🔥 TOP
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
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔥 INFO
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "\$125",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔥 PROGRESS
          _progress(),

          const SizedBox(height: 20),

          // 🔥 BUTTONS
          Row(
            children: [
              _btnOutline("View Details"),
              const SizedBox(width: 10),
              _btnOutline("Revision"),
              const SizedBox(width: 10),
              _btnGradient("Complete"),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 PROGRESS BAR
  Widget _progress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final active = index <= 1;

            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: active ? Colors.purpleAccent : Colors.white24,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Placed",
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              "Progress",
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              "Revision",
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text("Done", style: TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  // 🔥 BUTTON OUTLINE
  Widget _btnOutline(String text) {
    return Expanded(
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
    );
  }

  // 🔥 BUTTON GRADIENT
  Widget _btnGradient(String text) {
    return Expanded(
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
    );
  }

  // 🔥 EMPTY STATE
  Widget _emptyState(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.white54)),
    );
  }

  // 🔥 ICON BULAT
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
