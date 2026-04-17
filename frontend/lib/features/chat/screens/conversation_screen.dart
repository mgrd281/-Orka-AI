/// Orka AI — Conversation Screen
///
/// The main chat thread with streaming responses, agent thinking
/// indicators, and the "Denkprozess anzeigen" feature.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/api_service.dart';
import '../widgets/mode_selector.dart';
import '../widgets/agent_thinking_indicator.dart';
import '../widgets/message_bubble.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String _selectedMode = 'smart';
  bool _isSending = false;
  String _currentAgent = '';
  String _streamedContent = '';
  bool _showReasoning = false;
  List<Map<String, dynamic>> _reasoningSteps = [];

  @override
  void initState() {
    super.initState();
    _loadConversation();

    // Handle initial message from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra.containsKey('initialMessage')) {
        _sendMessage(extra['initialMessage'] as String);
        _selectedMode = extra['mode'] as String? ?? 'smart';
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getConversation(widget.conversationId);
      final messages = (data['messages'] as List?)?.map((m) {
        return ChatMessage(
          role: m['role'],
          content: m['content'],
          reasoning: m['reasoning_summary'],
        );
      }).toList();

      if (messages != null && mounted) {
        setState(() => _messages.addAll(messages));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _sendMessage([String? overrideContent]) async {
    final content = overrideContent ?? _textController.text.trim();
    if (content.isEmpty || _isSending) return;

    _textController.clear();
    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(role: 'user', content: content));
      _streamedContent = '';
      _currentAgent = '';
      _reasoningSteps = [];
    });
    _scrollToBottom();

    try {
      final api = ref.read(apiServiceProvider);

      await for (final event in api.sendMessageStream(
        conversationId: widget.conversationId,
        content: content,
        mode: _selectedMode,
      )) {
        if (!mounted) return;

        switch (event['type']) {
          case 'agent_start':
            setState(() => _currentAgent = event['display_name'] ?? event['agent']);
            break;
          case 'agent_complete':
            _reasoningSteps.add({
              'agent': event['agent'],
              'summary': event['summary'] ?? '',
            });
            break;
          case 'token':
            setState(() => _streamedContent += event['content']);
            _scrollToBottom();
            break;
          case 'complete':
            setState(() {
              _messages.add(ChatMessage(
                role: 'assistant',
                content: _streamedContent,
                reasoning: event['reasoning_summary'],
              ));
              _streamedContent = '';
              _currentAgent = '';
              _isSending = false;
            });
            break;
          case 'error':
            setState(() {
              _messages.add(ChatMessage(
                role: 'assistant',
                content: 'Es tut mir leid, ein Fehler ist aufgetreten. Bitte versuche es erneut.',
              ));
              _isSending = false;
            });
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_streamedContent.isNotEmpty) {
            _messages.add(ChatMessage(
              role: 'assistant',
              content: _streamedContent,
            ));
          }
          _isSending = false;
          _streamedContent = '';
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: OrkaColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 22),
          onPressed: () => context.go('/chat'),
        ),
        title: Text(
          'Orka AI',
          style: OrkaTypography.headlineSmall.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.more, size: 22),
            onPressed: () {
              // TODO: conversation options (rename, delete, export)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _messages.length +
                  (_isSending && _streamedContent.isNotEmpty ? 1 : 0) +
                  (_isSending && _streamedContent.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Existing messages
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return MessageBubble(
                    message: msg,
                    onShowReasoning: msg.reasoning != null
                        ? () => _showReasoningSheet(msg.reasoning!)
                        : null,
                  );
                }

                // Agent thinking indicator (before streaming starts)
                if (_isSending && _streamedContent.isEmpty && index == _messages.length) {
                  return AgentThinkingIndicator(
                    currentAgent: _currentAgent,
                    steps: _reasoningSteps,
                  );
                }

                // Streaming content
                if (_isSending && _streamedContent.isNotEmpty) {
                  return MessageBubble(
                    message: ChatMessage(
                      role: 'assistant',
                      content: _streamedContent,
                    ),
                    isStreaming: true,
                  );
                }

                return const SizedBox.shrink();
              },
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
                GestureDetector(
                  onTap: _isSending ? null : () => _sendMessage(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _isSending ? null : OrkaColors.primaryGradient,
                      color: _isSending ? OrkaColors.surfaceCard : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Iconsax.send_15,
                      color: _isSending ? OrkaColors.textTertiaryDark : Colors.white,
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

  void _showReasoningSheet(Map<String, dynamic> reasoning) {
    final l = AppLocalizations.of(context);
    final steps = reasoning['steps'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: OrkaColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OrkaColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l.chatShowReasoning,
              style: OrkaTypography.headlineSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Modus: ${reasoning['mode']} • Aufgabentyp: ${reasoning['task_type'] ?? 'allgemein'}',
              style: OrkaTypography.labelSmall.copyWith(color: OrkaColors.textTertiaryDark),
            ),
            const SizedBox(height: 20),

            // Agent steps
            ...steps.map((step) {
              final agentColor = _getAgentColor(step['agent'] ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: agentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['agent'] ?? '',
                            style: OrkaTypography.labelMedium.copyWith(
                              color: agentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['summary'] ?? '',
                            style: OrkaTypography.bodySmall.copyWith(
                              color: OrkaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${step['latency_ms'] ?? 0}ms',
                      style: OrkaTypography.labelSmall.copyWith(
                        color: OrkaColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getAgentColor(String agent) {
    switch (agent) {
      case 'analyst':
        return OrkaColors.agentAnalyst;
      case 'researcher':
        return OrkaColors.agentResearcher;
      case 'creative':
        return OrkaColors.agentCreative;
      case 'critic':
        return OrkaColors.agentCritic;
      case 'synthesizer':
        return OrkaColors.agentSynthesizer;
      case 'judge':
        return OrkaColors.agentJudge;
      default:
        return OrkaColors.primary;
    }
  }
}

/// Simple chat message model
class ChatMessage {
  final String role;
  final String content;
  final Map<String, dynamic>? reasoning;

  ChatMessage({
    required this.role,
    required this.content,
    this.reasoning,
  });
}
