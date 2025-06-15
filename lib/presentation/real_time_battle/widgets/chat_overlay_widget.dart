import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatOverlayWidget extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final Function(String) onSendMessage;
  final VoidCallback onClose;

  const ChatOverlayWidget({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.onClose,
  });

  @override
  State<ChatOverlayWidget> createState() => _ChatOverlayWidgetState();
}

class _ChatOverlayWidgetState extends State<ChatOverlayWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();

      // Scroll to bottom after sending message
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: Container(
        width: 70.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'chat',
                    color: AppTheme.darkTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Team Chat',
                    style: AppTheme.darkTheme.textTheme.titleSmall,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.darkTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8),
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final message = widget.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Input
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: AppTheme.darkTheme.textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        hintStyle:
                            AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.darkTheme.colorScheme.surface
                            .withValues(alpha: 0.5),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomIconWidget(
                        iconName: 'send',
                        color: AppTheme.darkTheme.colorScheme.onPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isAlly = message["isAlly"] as bool;
    final playerName = message["playerName"] as String;
    final messageText = message["message"] as String;
    final timestamp = message["timestamp"] as DateTime;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                playerName,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: isAlly
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.darkTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAlly
                  ? AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.2)
                  : AppTheme.darkTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              messageText,
              style: AppTheme.darkTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
