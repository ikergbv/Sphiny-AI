import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/message.dart';
import '../../../theme/app_theme.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(),
            SizedBox(width: 3.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                SizedBox(height: 0.5.h),
                _buildTimestamp(),
              ],
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 3.w),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryLight, AppTheme.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copyToClipboard(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageText(),
            if (!message.isUser && message.textContent.isNotEmpty)
              _buildCopyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText() {
    return Text(
      message.textContent,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: message.isUser ? Colors.white : Colors.grey[800],
        height: 1.4,
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => _copyToClipboard(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 1.w),
                Text(
                  'Copiar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    final timeStr = '${message.timestamp.hour.toString().padLeft(2, '0')}:'
        '${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Text(
      timeStr,
      style: GoogleFonts.inter(
        fontSize: 11,
        color: Colors.grey[500],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.textContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mensaje copiado al portapapeles',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        backgroundColor: AppTheme.primaryLight,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
