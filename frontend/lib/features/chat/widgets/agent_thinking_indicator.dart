/// Orka AI — Agent Thinking Indicator
///
/// Premium animated indicator showing which agents are currently
/// working on the user's prompt. Orbital animation with agent names.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class AgentThinkingIndicator extends StatelessWidget {
  final String currentAgent;
  final List<Map<String, dynamic>> steps;

  const AgentThinkingIndicator({
    super.key,
    required this.currentAgent,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrkaColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OrkaColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pulsing indicator
          Row(
            children: [
              // Pulsing dot
              _PulsingDot(),
              const SizedBox(width: 12),
              Text(
                l.chatThinking,
                style: OrkaTypography.labelLarge.copyWith(
                  color: OrkaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (currentAgent.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Current agent
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: OrkaColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  currentAgent,
                  style: OrkaTypography.bodySmall.copyWith(
                    color: OrkaColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                // Animated dots
                _AnimatedDots(),
              ],
            ).animate().fadeIn(duration: 300.ms),
          ],

          // Completed steps
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: OrkaColors.success,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      step['summary'] ?? step['agent'] ?? '',
                      style: OrkaTypography.bodySmall.copyWith(
                        color: OrkaColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms);
            }),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: OrkaColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: OrkaColors.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _AnimatedDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: OrkaColors.textTertiaryDark,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: Duration(milliseconds: i * 200))
            .then()
            .fadeOut(delay: 600.ms);
      }),
    );
  }
}
