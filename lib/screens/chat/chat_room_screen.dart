import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/message_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatRoomScreen({super.key, required this.otherUserId, required this.otherUserName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messageService = MessageService();
  final _authService = AuthService();

  List<MessageModel> _messages = [];
  String? _myUserId;
  String? _lastServerTime;
  Timer? _pollTimer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await _authService.getUserId();
    await _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final data = await _messageService.pollMessages(withUserId: widget.otherUserId, after: _lastServerTime);
      final newMsgs = (data['messages'] as List).map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
      if (!mounted) return;
      if (newMsgs.isNotEmpty) {
        setState(() {
          _messages.addAll(newMsgs);
          _lastServerTime = data['serverTime'] as String?;
        });
        _scrollToBottom();
      } else {
        _lastServerTime = data['serverTime'] as String?;
      }
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _messageCtrl.clear();
    setState(() => _sending = true);
    try {
      final data = await _messageService.sendMessage(receiverId: widget.otherUserId, message: text);
      if (!mounted) return;
      setState(() => _messages.add(MessageModel.fromJson(data)));
      _scrollToBottom();
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageModel msg) {
    final isMe = msg.senderId == _myUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
              : null,
          color: isMe ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: isMe ? null : [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.message, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(msg.createdAt.toLocal()),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _messageCtrl,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: _sending
                ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
