/// Orka AI — Chat Screen (New Chat / Empty State)
///
/// Premium empty state with suggested prompts and mode selector.
/// This is the first screen users see after auth.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/api_service.dart';
import '../widgets/mode_selector.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  String _selectedMode = 'smart';
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final api = ref.read(apiServiceProvider);
      final conv = await api.createConversation(mode: _selectedMode);
      final convId = conv['id'] as String;

      if (mounted) {
        context.go('/chat/$convId', extra: {
          'initialMessage': content,
          'mode': _selectedMode,
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: OrkaColors.surfaceDark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: OrkaColors.premiumGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('O', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Text('Orka AI', style: OrkaTypography.headlineSmall.copyWith(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.clock, size: 22),
            onPressed: () {
              // TODO: show conversation history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Empty state content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: OrkaColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        size: 36,
                        color: OrkaColors.primary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 24),

                    Text(
                      l.chatEmpty,
                      style: OrkaTypography.displaySmall.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                    const SizedBox(height: 12),

                    Text(
                      l.chatEmptyHint,
                      style: OrkaTypography.bodyMedium.copyWith(
                        color: OrkaColors.textSecondaryDark,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                    const SizedBox(height: 40),

                    // Suggested prompts
                    ..._buildSuggestedPrompts(l),
                  ],
                ),
              ),
            ),
          ),

          // Mode selector
          ModeSelector(
            selectedMode: _selectedMode,
            onModeChanged: (mode) => setState(() => _selectedMode = mode),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
            decoration: BoxDecoration(
              color: OrkaColors.surfaceDark,
              border: Border(
                top: BorderSide(
                  color: OrkaColors.borderDark.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: OrkaColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OrkaColors.borderDark, width: 0.5),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      style: OrkaTypography.bodyMedium.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l.chatPlaceholder,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send button
                GestureDetector(
                  onTap: _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: OrkaColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: OrkaColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isSending
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Iconsax.send_15,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSuggestedPrompts(AppLocalizations l) {
    final prompts = [
      ('✍️', 'Schreibe einen überzeugenden LinkedIn-Post über KI'),
      ('📊', 'Analysiere Vor- und Nachteile von Remote-Arbeit'),
      ('💡', 'Erkläre Quantencomputing einfach und verständlich'),
      ('🚀', 'Erstelle einen Businessplan für eine App-Idee'),
    ];

    return prompts
        .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SuggestedPromptCard(
                emoji: p.$1,
                text: p.$2,
                onTap: () {
                  _textController.text = p.$2;
                  _sendMessage();
                },
              ),
            ))
        .toList()
        .animate(interval: 100.ms)
        .fadeIn(duration: 400.ms, delay: 600.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

class _SuggestedPromptCard extends StatelessWidget {
  final String emoji;
  final String text;
  final VoidCallback onTap;

  const _SuggestedPromptCard({
    required this.emoji,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: OrkaColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: OrkaColors.borderDark, width: 0.5),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: OrkaTypography.bodySmall.copyWith(
                    color: OrkaColors.textSecondaryDark,
                  ),
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: OrkaColors.textTertiaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
