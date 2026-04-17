/// Orka AI — Message Bubble Widget
///
/// Premium message bubbles for user and assistant messages.
/// Supports markdown rendering, copy, share, and reasoning toggle.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../screens/conversation_screen.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  final VoidCallback? onShowReasoning;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onShowReasoning,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final l = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isUser ? OrkaColors.primary : OrkaColors.surfaceCard,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser
                  ? null
                  : Border.all(color: OrkaColors.borderDark, width: 0.5),
            ),
            child: isUser
                ? Text(
                    message.content,
                    style: OrkaTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  )
                : MarkdownBody(
                    data: message.content + (isStreaming ? '▊' : ''),
                    styleSheet: MarkdownStyleSheet(
                      p: OrkaTypography.bodyMedium.copyWith(
                        color: OrkaColors.textPrimaryDark,
                        height: 1.6,
                      ),
                      h1: OrkaTypography.headlineLarge.copyWith(color: Colors.white),
                      h2: OrkaTypography.headlineMedium.copyWith(color: Colors.white),
                      h3: OrkaTypography.headlineSmall.copyWith(color: Colors.white),
                      code: OrkaTypography.code.copyWith(
                        color: OrkaColors.secondary,
                        backgroundColor: OrkaColors.surfaceElevated,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: OrkaColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: OrkaColors.primary.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                      ),
                      listBullet: OrkaTypography.bodyMedium.copyWith(
                        color: OrkaColors.textSecondaryDark,
                      ),
                      strong: const TextStyle(fontWeight: FontWeight.w600),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    selectable: true,
                  ),
          ),

          // Actions for assistant messages
          if (!isUser && !isStreaming) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Iconsax.copy,
                  label: l.chatCopy,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kopiert', style: OrkaTypography.bodySmall),
                        backgroundColor: OrkaColors.surfaceCard,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                if (message.reasoning != null) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Iconsax.cpu,
                    label: l.chatShowReasoning,
                    onTap: onShowReasoning,
                    highlight: true,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: highlight
              ? OrkaColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: highlight ? OrkaColors.primary : OrkaColors.textTertiaryDark,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: OrkaTypography.labelSmall.copyWith(
                color: highlight ? OrkaColors.primary : OrkaColors.textTertiaryDark,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
