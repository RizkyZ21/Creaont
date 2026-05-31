import 'package:flutter/material.dart';

import '../order/service_option_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> services = [
    {"title": "Logo Modern", "price": "Rp 100.000", "category": "Logo"},
    {"title": "Banner Gaming", "price": "Rp 150.000", "category": "Branding"},
    {"title": "UI Mobile App", "price": "Rp 300.000", "category": "UI/UX"},
  ];

  List<Map<String, String>> filteredServices = [];

  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    filteredServices = services;
  }

  void filter() {
    final query = searchController.text.toLowerCase();

    final results = services.where((item) {
      final title = (item['title'] ?? '').toLowerCase();
      final category = item['category'] ?? '';

      final matchSearch = title.contains(query);
      final matchCategory =
          selectedCategory == "All" || category == selectedCategory;

      return matchSearch && matchCategory;
    }).toList();

    setState(() {
      filteredServices = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Explore",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => filter(),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search, color: Colors.white54),
                              hintText: "Search services...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _category("All"),
                        _category("UI/UX"),
                        _category("Logo"),
                        _category("Branding"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredServices.isEmpty
                  ? const Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredServices.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final item = filteredServices[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceOptionScreen(
                                  title: item['title'] ?? '',
                                  price: item['price'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7F00FF),
                                        Color(0xFFE100FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.design_services,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['category'] ?? 'DESIGN',
                                        style: const TextStyle(
                                          color: Colors.purpleAccent,
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        item['title'] ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Designer",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        item['price'] ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _category(String text) {
    final isActive = selectedCategory == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
        filter();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                )
              : null,
          color: isActive ? null : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isActive ? Colors.white : Colors.white54),
        ),
      ),
    );
  }
}
