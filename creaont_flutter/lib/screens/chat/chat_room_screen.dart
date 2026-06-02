import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import 'dart:async';

class ChatRoomScreen extends StatefulWidget {
  final int orderId;
  final String otherName;
  final String orderTitle;
  final String token;
  final String myRole;

  const ChatRoomScreen({
    super.key,
    required this.orderId,
    required this.otherName,
    required this.orderTitle,
    required this.token,
    required this.myRole,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgCtrl     = TextEditingController();
  final _scrollCtrl  = ScrollController();
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // Poll setiap 5 detik untuk pesan baru
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);
    final res = await ChatService.getMessages(token: widget.token, orderId: widget.orderId);
    if (mounted) {
      final newMessages = res['success'] == true ? (res['data'] as List) : messages;
      final hadNew = newMessages.length > messages.length;
      setState(() {
        isLoading = false;
        messages = newMessages;
      });
      if (hadNew) _scrollToBottom();
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || isSending) return;
    setState(() => isSending = true);
    _msgCtrl.clear();

    final res = await ChatService.sendMessage(
      token: widget.token, orderId: widget.orderId, message: text,
    );
    if (mounted) {
      setState(() => isSending = false);
      if (res['success'] == true) {
        await _load(silent: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal kirim pesan'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              radius: 18,
              child: Text(widget.otherName.isNotEmpty ? widget.otherName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherName, style: const TextStyle(fontSize: 15, color: Colors.white)),
                  Text(widget.orderTitle, style: const TextStyle(fontSize: 11, color: Colors.white54),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                : messages.isEmpty
                    ? const Center(child: Text('Belum ada pesan. Mulai percakapan!',
                        style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final isMe = msg['sender_type'] == widget.myRole;
                          final senderName = msg['sender']?['name'] ?? '';
                          final time = _formatTime(msg['created_at']);

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                                    child: Text(senderName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  decoration: BoxDecoration(
                                    gradient: isMe
                                        ? const LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFFE100FF)])
                                        : null,
                                    color: isMe ? null : const Color(0xFF1E1B3A),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(msg['message'] ?? '', style: const TextStyle(color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text(time, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFF1A1733)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF26213F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 46, height: 46,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFFE100FF)]),
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}
