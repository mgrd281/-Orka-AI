/// Orka AI — Subscription Screen
///
/// Plan comparison cards with premium gradients:
/// Kostenlos (Free) | Pro €9.99 | Premium €24.99

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/api_service.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _currentPlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final api = ref.read(apiServiceProvider);
      final profile = await api.getProfile();
      setState(() {
        _currentPlan = profile['subscription_plan'] ?? 'free';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: OrkaColors.surfaceDark,
        title: Text(l.subscriptionTitle, style: OrkaTypography.headlineSmall.copyWith(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: OrkaColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.subscriptionChoosePlan,
                    style: OrkaTypography.displaySmall.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wähle den Plan, der zu deinen Anforderungen passt.',
                    style: OrkaTypography.bodyMedium.copyWith(color: OrkaColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 32),

                  // Free
                  _PlanCard(
                    name: l.planFree,
                    price: '€0',
                    period: '/ ${l.planMonth}',
                    features: [
                      '15 Nachrichten / Tag',
                      'Schnell-Modus',
                      'Basisantworten',
                    ],
                    isCurrent: _currentPlan == 'free',
                    onSelect: null, // free is default
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // Pro
                  _PlanCard(
                    name: l.planPro,
                    price: '€9.99',
                    period: '/ ${l.planMonth}',
                    features: [
                      '150 Nachrichten / Tag',
                      'Smart & Schnell Modus',
                      'Denkprozess-Anzeige',
                      'Gesprächsexport',
                    ],
                    isCurrent: _currentPlan == 'pro',
                    isPremium: true,
                    gradient: OrkaColors.primaryGradient,
                    onSelect: () => _subscribe('pro'),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // Premium
                  _PlanCard(
                    name: l.planPremium,
                    price: '€24.99',
                    period: '/ ${l.planMonth}',
                    features: [
                      'Unbegrenzte Nachrichten',
                      'Alle Modi inkl. Tief',
                      'Denkprozess-Anzeige',
                      'Prioritäts-Verarbeitung',
                      'Frühzugang zu Features',
                    ],
                    isCurrent: _currentPlan == 'premium',
                    gradient: OrkaColors.premiumGradient,
                    onSelect: () => _subscribe('premium'),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05),
                ],
              ),
            ),
    );
  }

  Future<void> _subscribe(String planId) async {
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.createCheckout(planId);
      final url = result['checkout_url'] as String?;
      if (url != null) {
        // TODO: open Stripe checkout in webview or system browser
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Erstellen des Checkouts'),
            backgroundColor: OrkaColors.error,
          ),
        );
      }
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isCurrent;
  final bool isPremium;
  final LinearGradient? gradient;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.isCurrent,
    this.isPremium = false,
    this.gradient,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrkaColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent
            ? Border.all(color: OrkaColors.primary, width: 2)
            : Border.all(color: OrkaColors.borderDark, width: 0.5),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: OrkaColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + badge
          Row(
            children: [
              Text(name, style: OrkaTypography.headlineMedium.copyWith(color: Colors.white)),
              if (isCurrent) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: OrkaColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Aktiv', style: OrkaTypography.labelSmall.copyWith(color: OrkaColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              gradient != null
                  ? ShaderMask(
                      shaderCallback: (bounds) => gradient!.createShader(bounds),
                      child: Text(price, style: OrkaTypography.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    )
                  : Text(price, style: OrkaTypography.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(period, style: OrkaTypography.bodySmall.copyWith(color: OrkaColors.textTertiaryDark)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Features
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: OrkaColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f, style: OrkaTypography.bodySmall.copyWith(color: OrkaColors.textSecondaryDark)),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // CTA
          if (!isCurrent && onSelect != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradient != null ? null : OrkaColors.surfaceElevated,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Ink(
                  decoration: gradient != null
                      ? BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14))
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l.subscriptionUpgrade,
                      style: OrkaTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
