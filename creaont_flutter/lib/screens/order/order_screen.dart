import 'package:flutter/material.dart';

import 'order_detail_screen.dart';
import '../chat/chat_room_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),

        elevation: 0,

        title: const Text('Orders', style: TextStyle(color: Colors.white)),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Card(
            color: const Color(0xFF1E1B3A),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: const Text(
                      'Logo Design Project',

                      style: TextStyle(color: Colors.white),
                    ),

                    subtitle: const Text(
                      'Status: In Progress',

                      style: TextStyle(color: Colors.white54),
                    ),

                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        "Progress",

                        style: TextStyle(color: Colors.purpleAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,

                            side: const BorderSide(color: Colors.white24),
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const OrderDetailScreen(),
                              ),
                            );
                          },

                          child: const Text("Detail"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const ChatRoomScreen(
                                  name: "Alex Designer",

                                  image: "https://i.pravatar.cc/150?img=1",
                                ),
                              ),
                            );
                          },

                          child: const Text("Chat"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
