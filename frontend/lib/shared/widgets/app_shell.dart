/// Orka AI — App Shell
///
/// Main navigation scaffold with bottom navigation bar.
/// Elegant, minimal, with premium spacing.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location.startsWith('/chat')) currentIndex = 0;
    if (location.startsWith('/settings')) currentIndex = 1;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Iconsax.message,
                  activeIcon: Iconsax.message5,
                  label: l.navChat,
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/chat'),
                ),
                _NavItem(
                  icon: Iconsax.setting_2,
                  activeIcon: Iconsax.setting_25,
                  label: l.navSettings,
                  isActive: currentIndex == 1,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? OrkaColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? OrkaColors.primary : OrkaColors.textTertiaryDark,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? OrkaColors.primary : OrkaColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
