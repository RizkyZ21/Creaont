import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> chats = [
    {
      "name": "Alex Designer",
      "message": "Sure, I can start working on this tomorrow",
      "time": "10:30 AM",
      "unread": 2,
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Sarah Create",
      "message": "Here is the final delivery for your branding project",
      "time": "Yesterday",
      "unread": 0,
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Mike Logo",
      "message": "Thanks for the feedback! I'll revise it.",
      "time": "Monday",
      "unread": 0,
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  List<Map<String, dynamic>> filteredChats = [];

  @override
  void initState() {
    super.initState();
    filteredChats = chats;
  }

  void searchChat(String query) {
    final result = chats.where((chat) {
      final name = chat['name'].toLowerCase();
      final message = chat['message'].toLowerCase();
      final input = query.toLowerCase();

      return name.contains(input) || message.contains(input);
    }).toList();

    setState(() {
      filteredChats = result;
    });
  }

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
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _circleIcon(Icons.edit),
                      const SizedBox(width: 10),
                      _circleIcon(Icons.more_vert),
                    ],
                  ),
                ],
              ),
            ),

            // 🔥 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: searchChat,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1B3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 LIST CHAT
            Expanded(
              child: ListView.builder(
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B3A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        // 🔥 AVATAR
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(chat['image']),
                            ),
                            if (chat['unread'] > 0)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // 🔥 TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat['message'],
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 🔥 TIME + UNREAD
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              chat['time'],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (chat['unread'] > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.purpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chat['unread'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

  // 🔥 ICON BULAT
  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
