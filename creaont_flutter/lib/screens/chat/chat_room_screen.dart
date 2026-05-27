import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String name;
  final String image;

  const ChatRoomScreen({super.key, required this.name, required this.image});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {"text": "Hello, how can I help you?", "me": false},

    {"text": "I need a logo design", "me": true},
  ];

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      messages.add({"text": messageController.text, "me": true});
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.image)),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.name,

                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),

                const Text(
                  "Online",

                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg["me"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,

                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: msg["me"]
                          ? Colors.purple
                          : const Color(0xFF1E1B3A),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Text(
                      msg["text"],

                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),

            decoration: const BoxDecoration(color: Color(0xFF1A1733)),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "Type message...",

                      hintStyle: const TextStyle(color: Colors.white54),

                      filled: true,

                      fillColor: const Color(0xFF26213F),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 24,

                  backgroundColor: Colors.purple,

                  child: IconButton(
                    onPressed: sendMessage,

                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
