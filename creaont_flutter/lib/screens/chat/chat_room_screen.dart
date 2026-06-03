import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import 'dart:async';

class ChatRoomScreen extends StatefulWidget {
  final int orderId;           // order representatif (untuk kirim pesan baru)
  final String otherName;
  final String orderTitle;
  final String token;
  final String myRole;
  final List<int> groupOrderIds; // semua order dalam group (untuk load semua chat)

  const ChatRoomScreen({
    super.key,
    required this.orderId,
    required this.otherName,
    required this.orderTitle,
    required this.token,
    required this.myRole,
    this.groupOrderIds = const [],
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  Timer? _pollTimer;

  // Order IDs yang digunakan untuk load chat
  List<int> get _allOrderIds {
    final ids = widget.groupOrderIds.isNotEmpty
        ? widget.groupOrderIds
        : [widget.orderId];
    return ids;
  }

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _load(silent: true),
    );
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

    // Ambil pesan dari semua order dalam group, gabung & sort by created_at
    final List<dynamic> allMessages = [];
    for (final id in _allOrderIds) {
      final res = await ChatService.getMessages(
          token: widget.token, orderId: id);
      if (res['success'] == true) {
        final msgs = (res['data'] as List?) ?? [];
        // Tag setiap pesan dengan order_id-nya agar kita tau dari order mana
        for (final m in msgs) {
          if (m is Map) {
            (m as Map<dynamic, dynamic>)['_order_id'] = id;
          }
        }
        allMessages.addAll(msgs);
      }
    }

    // Sort by created_at ascending
    allMessages.sort((a, b) {
      final ta = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
      final tb = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
      return ta.compareTo(tb);
    });

    if (mounted) {
      final hadNew = allMessages.length > messages.length;
      setState(() {
        isLoading = false;
        messages = allMessages;
      });
      if (hadNew) _scrollToBottom();
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || isSending) return;
    setState(() => isSending = true);
    _msgCtrl.clear();

    // Kirim ke orderId yang representatif (terbaru / paling aktif)
    final res = await ChatService.sendMessage(
      token: widget.token,
      orderId: widget.orderId,
      message: text,
    );
    if (mounted) {
      setState(() => isSending = false);
      if (res['success'] == true) {
        await _load(silent: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal kirim pesan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = _allOrderIds.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF0288D1),
              radius: 18,
              child: Text(
                widget.otherName.isNotEmpty
                    ? widget.otherName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherName,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  Text(
                    isGroup
                        ? '${_allOrderIds.length} order · ${widget.orderTitle}'
                        : widget.orderTitle,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner jumlah order dalam group
          if (isGroup)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0288D1).withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined,
                      color: Colors.lightBlueAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Chat digabung dari ${_allOrderIds.length} order',
                    style: const TextStyle(
                        color: Colors.lightBlueAccent, fontSize: 12),
                  ),
                ],
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent))
                : messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada pesan. Mulai percakapan!',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final isMe =
                              msg['sender_type'] == widget.myRole;
                          final senderName =
                              msg['sender']?['name'] ?? '';
                          final time =
                              _formatTime(msg['created_at']);

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 2),
                                    child: Text(
                                      senderName,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11),
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isMe
                                        ? const LinearGradient(colors: [
                                            Color(0xFF0288D1),
                                            Color(0xFF29B6F6),
                                          ])
                                        : null,
                                    color: isMe
                                        ? null
                                        : const Color(0xFF0D1F3C),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft:
                                          Radius.circular(isMe ? 16 : 4),
                                      bottomRight:
                                          Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        msg['message'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        time,
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Input
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send,
                            color: Colors.white, size: 20),
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
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
