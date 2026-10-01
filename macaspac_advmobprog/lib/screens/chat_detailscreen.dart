import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(receiverId: widget.user.uid, text: text);
      _messageController.clear();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMine = message.isFromCurrentUser;
    final bubbleColor = isMine
        ? const Color(0xFF6B4BB2)
        : const Color(0xFFEDE7F6);
    final textColor = isMine ? Colors.white : Colors.black87;
    final statusIcon = message.status == 'seen'
        ? Icons.done_all_rounded
        : message.status == 'sent'
        ? Icons.done_rounded
        : Icons.access_time_rounded;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(
          left: isMine ? 68.w : 12.w,
          right: isMine ? 12.w : 68.w,
          top: 8.h,
          bottom: 8.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15.sp, height: 1.35),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMine ? Colors.white70 : Colors.black54,
                    fontSize: 10.sp,
                  ),
                ),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    statusIcon,
                    color: message.status == 'seen'
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                    size: 14.sp,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF6B4BB2);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: purple.withValues(alpha: 0.15),
              backgroundImage: widget.user.photoUrl.isNotEmpty
                  ? NetworkImage(widget.user.photoUrl)
                  : null,
              child: widget.user.photoUrl.isEmpty
                  ? Text(
                      widget.user.name.isNotEmpty
                          ? widget.user.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
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
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.watchMessages(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? const <ChatMessage>[];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Send the first message to start the conversation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 250),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero,
                                )
                                .chain(CurveTween(curve: Curves.easeOutCubic))
                                .animate(AlwaysStoppedAnimation(1.0)),
                        child: _buildMessageBubble(message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isSending)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              color: Colors.white,
              child: Text(
                'sending...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: purple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F3FA),
                      hintText: 'Write a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                FloatingActionButton(
                  onPressed: _isSending ? null : _sendMessage,
                  mini: true,
                  backgroundColor: purple,
                  child: Icon(
                    _isSending
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    size: 20.sp,
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
