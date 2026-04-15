import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final designs = [
      {"title": "Logo Modern", "price": "Rp 100.000"},
      {"title": "Banner Gaming", "price": "Rp 150.000"},
      {"title": "UI Mobile App", "price": "Rp 300.000"},
    ];

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 🔥 HEADER (ganti AppBar)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Text(
                  "Creaont",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔥 LIST
          Expanded(
            child: ListView.builder(
              itemCount: designs.length,
              itemBuilder: (context, index) {
                final item = designs[index];

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.design_services,
                      color: Colors.purpleAccent,
                    ),
                    title: Text(
                      item['title']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      item['price']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
