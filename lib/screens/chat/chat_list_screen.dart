import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../services/message_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _service = MessageService();
  List<dynamic> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final convos = await _service.getConversations();
      if (!mounted) return;
      setState(() { _conversations = convos; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _conversations.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) {
                      final c = _conversations[i] as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: c['profilePhoto'] != null ? NetworkImage(c['profilePhoto'] as String) : null,
                          child: c['profilePhoto'] == null
                              ? Text((c['name'] as String).isNotEmpty ? (c['name'] as String)[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c['lastMessage'] as String? ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(c['lastMessageAt'] as String?),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            if ((c['unreadCount'] as int? ?? 0) > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: Text('${c['unreadCount']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(otherUserId: c['userId'] as String, otherUserName: c['name'] as String),
                        )).then((_) => _load()),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.border),
      SizedBox(height: 16),
      Text('No conversations yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      SizedBox(height: 8),
      Text('Start a chat from a doctor profile', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ]));
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month) return DateFormat('hh:mm a').format(dt);
    return DateFormat('MMM dd').format(dt);
  }
}
