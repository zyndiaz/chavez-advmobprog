import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chavez_advmobprog2627/widgets/custom_text.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';

final ChatService chatService = ChatService();

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  final Set<String> _seenUpdatesInProgress = {};

  late Future<String> _currentUserIdFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();
  }

  Future<String> _getCurrentUserId() async {
    final userData = await userService.value.getUserData();
    return (userData['uid'] ?? '').toString();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await chatService.sendMessage(receiverId, text);
      _msgCtrl.clear();
      _msgFocus.requestFocus();

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();
    final tappedUserName = [
      widget.tappedUser['firstName'],
      widget.tappedUser['lastName'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    final displayName = tappedUserName.isNotEmpty
        ? tappedUserName
        : (widget.tappedUser['username'] ?? 'Chat').toString();

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final currentUserId = snap.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A237E),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: displayName,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: (widget.tappedUser['email'] ?? '').toString(),
                  fontSize: 11.sp,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessage(currentUserId, tappedUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading messages: ${snapshot.error}',
                        ),
                      );
                    }

                    List<QueryDocumentSnapshot> docs =
                        snapshot.data?.docs ?? [];

                    _markIncomingMessagesSeen(
                      docs,
                      currentUserId,
                      tappedUserId,
                    );

                    if (docs.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final msgText = (data['message'] ?? '').toString();
                        final senderId = (data['senderId'] ?? '').toString();
                        final isMe = senderId == currentUserId;
                        final status = (data['status'] ?? 'delivered')
                            .toString();

                        return TweenAnimationBuilder<double>(
                          key: ValueKey(docs[index].id),
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          builder: (context, progress, child) => Opacity(
                            opacity: progress,
                            child: Transform.translate(
                              offset: Offset(
                                (isMe ? 12 : -12) * (1 - progress),
                                0,
                              ),
                              child: child,
                            ),
                          ),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF1A237E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18)
                                    .copyWith(
                                      bottomLeft: isMe
                                          ? const Radius.circular(18)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(18),
                                    ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomText(
                                    text: msgText,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal,
                                    color: isMe ? Colors.white : Colors.black87,
                                    textAlign: TextAlign.left,
                                  ),
                                  if (isMe) ...[
                                    SizedBox(height: 3.h),
                                    Icon(
                                      status == 'seen'
                                          ? Icons.done_all
                                          : status == 'delivered'
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 15.sp,
                                      color: status == 'seen'
                                          ? const Color(0xFF80D8FF)
                                          : Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Composer
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _msgFocus,
                          enabled: !_isSending,
                          textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (_) => !_isSending
                              ? _send(currentUserId, tappedUserId)
                              : null,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(fontFamily: 'Poppins'),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isSending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14.w,
                                  height: 14.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                CustomText(text: 'Sending...', fontSize: 11.sp),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () =>
                                  _send(currentUserId, tappedUserId),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _markIncomingMessagesSeen(
    List<QueryDocumentSnapshot> docs,
    String currentUserId,
    String otherUserId,
  ) {
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['receiverId'] != currentUserId || data['status'] == 'seen') {
        continue;
      }
      if (!_seenUpdatesInProgress.add(doc.id)) continue;
      chatService
          .markMessageSeen(doc.id, currentUserId, otherUserId)
          .catchError((_) {
            _seenUpdatesInProgress.remove(doc.id);
          });
    }
  }
}
