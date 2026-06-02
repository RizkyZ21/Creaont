import 'package:flutter/material.dart';

import 'order_detail_screen.dart';
import '../chat/chat_room_screen.dart';

/// Screen placeholder — data dummy untuk preview desain saja.
/// Navigasi nyata ada di OrdersTab yang sudah pakai data live.
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  // Dummy data untuk preview
  static const _dummyOrderId  = 1;
  static const _dummyToken    = '';
  static const _dummyRole     = 'customer';
  static const _dummyOther    = 'Alex Designer';
  static const _dummyTitle    = 'Logo Design Project';

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
                      _dummyTitle,
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
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        'Progress',
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
                                builder: (_) => const OrderDetailScreen(
                                  orderId: _dummyOrderId,
                                  token: _dummyToken,
                                  role: _dummyRole,
                                ),
                              ),
                            );
                          },

                          child: const Text('Detail'),
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
                                  orderId: _dummyOrderId,
                                  otherName: _dummyOther,
                                  orderTitle: _dummyTitle,
                                  token: _dummyToken,
                                  myRole: _dummyRole,
                                ),
                              ),
                            );
                          },

                          child: const Text('Chat'),
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
