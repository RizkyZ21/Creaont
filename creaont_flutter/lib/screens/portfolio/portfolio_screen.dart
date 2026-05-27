import 'package:flutter/material.dart';
import 'upload_design_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  static List<Map<String, dynamic>> portfolios = [];

  Future<void> goUpload() async {
    final result = await Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => const UploadDesignScreen()),
    );

    if (result != null) {
      setState(() {
        portfolios.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(
        title: const Text("Portfolio"),

        backgroundColor: Colors.transparent,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,

        onPressed: goUpload,

        child: const Icon(Icons.add),
      ),

      body: portfolios.isEmpty
          ? const Center(
              child: Text(
                "Belum ada portfolio",

                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: portfolios.length,

              itemBuilder: (context, index) {
                final item = portfolios[index];

                return Container(
                  margin: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white10,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: ListTile(
                    leading: item["image"] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: Image.file(
                              item["image"],

                              width: 60,
                              height: 60,

                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.white),

                    title: Text(
                      item["title"],

                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      item["desc"],

                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
