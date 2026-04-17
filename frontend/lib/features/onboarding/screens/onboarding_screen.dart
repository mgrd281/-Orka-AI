/// Orka AI — Onboarding Screen
///
/// Premium 3-slide onboarding with elegant animations.
/// Communicates the multi-agent intelligence value proposition.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: () => context.go('/auth'),
                  child: Text(
                    l.onboardingSkip,
                    style: OrkaTypography.labelLarge.copyWith(
                      color: OrkaColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _OnboardingPage(
                    title: l.onboardingTitle1,
                    description: l.onboardingDesc1,
                    icon: Icons.hub_rounded,
                    gradient: OrkaColors.premiumGradient,
                  ),
                  _OnboardingPage(
                    title: l.onboardingTitle2,
                    description: l.onboardingDesc2,
                    icon: Icons.auto_awesome_rounded,
                    gradient: const LinearGradient(
                      colors: [OrkaColors.secondary, Color(0xFF00E6A0)],
                    ),
                  ),
                  _OnboardingPage(
                    title: l.onboardingTitle3,
                    description: l.onboardingDesc3,
                    icon: Icons.speed_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), OrkaColors.primary],
                    ),
                  ),
                ],
              ),
            ),

            // Indicators & CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
              child: Column(
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? OrkaColors.primary
                              : OrkaColors.borderDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrkaColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 2 ? l.onboardingGetStarted : l.onboardingNext,
                        style: OrkaTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with gradient glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: OrkaColors.primary.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: Colors.white),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: OrkaTypography.displayLarge.copyWith(
              color: Colors.white,
              height: 1.15,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: OrkaTypography.bodyLarge.copyWith(
              color: OrkaColors.textSecondaryDark,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 600.ms)
              .slideY(begin: 0.15, end: 0),
        ],
      ),
    );
  }
}
