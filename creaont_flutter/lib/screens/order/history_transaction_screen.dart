import 'package:flutter/material.dart';

class HistoryTransactionScreen extends StatelessWidget {
  const HistoryTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(title: const Text("Transaction History")),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: const [
          Card(
            color: Color(0xFF1E1B3A),

            child: ListTile(
              title: Text("Logo Design", style: TextStyle(color: Colors.white)),

              subtitle: Text(
                "Completed",

                style: TextStyle(color: Colors.white54),
              ),

              trailing: Text("\$75", style: TextStyle(color: Colors.green)),
            ),
          ),

          SizedBox(height: 10),

          Card(
            color: Color(0xFF1E1B3A),

            child: ListTile(
              title: Text("UI Design", style: TextStyle(color: Colors.white)),

              subtitle: Text(
                "Completed",

                style: TextStyle(color: Colors.white54),
              ),

              trailing: Text("\$125", style: TextStyle(color: Colors.green)),
            ),
          ),
        ],
      ),
    );
  }
}
