/// Orka AI — Mode Selector Widget
///
/// Elegant horizontal mode picker: Schnell | Smart | Tief
/// Shows active mode with premium animation.

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class ModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModeChip(
            icon: Iconsax.flash_1,
            label: l.modeFast,
            isSelected: selectedMode == 'fast',
            color: OrkaColors.success,
            onTap: () => onModeChanged('fast'),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            icon: Iconsax.cpu,
            label: l.modeSmart,
            isSelected: selectedMode == 'smart',
            color: OrkaColors.primary,
            onTap: () => onModeChanged('smart'),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            icon: Iconsax.brain,
            label: l.modeDeep,
            isSelected: selectedMode == 'deep',
            color: OrkaColors.secondary,
            onTap: () => onModeChanged('deep'),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.4) : OrkaColors.borderDark,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : OrkaColors.textTertiaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: OrkaTypography.labelMedium.copyWith(
                color: isSelected ? color : OrkaColors.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
