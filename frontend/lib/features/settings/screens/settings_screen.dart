/// Orka AI — Settings Screen
///
/// Grouped settings: Profile, Sprache, Erscheinungsbild,
/// Standard-Modus, Abonnement, Datenschutz.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: OrkaColors.surfaceDark,
        title: Text(l.settingsTitle, style: OrkaTypography.headlineSmall.copyWith(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Language
          _SectionHeader(l.settingsLanguage),
          _SettingsTile(
            icon: Iconsax.language_circle,
            title: l.settingsLanguage,
            subtitle: _languageLabel(locale.languageCode),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          const SizedBox(height: 24),

          // Subscription
          _SectionHeader(l.settingsSubscription),
          _SettingsTile(
            icon: Iconsax.crown_1,
            title: l.settingsSubscription,
            subtitle: l.settingsManageSub,
            onTap: () => context.go('/subscription'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: OrkaColors.premiumGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Pro', style: OrkaTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 24),

          // Appearance
          _SectionHeader(l.settingsAppearance),
          _SettingsTile(
            icon: Iconsax.moon,
            title: l.settingsAppearance,
            subtitle: 'Dunkel',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Privacy
          _SectionHeader(l.settingsPrivacy),
          _SettingsTile(
            icon: Iconsax.shield_tick,
            title: l.settingsPrivacy,
            subtitle: 'Datenverarbeitung & Löschung',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.trash,
            title: l.settingsDeleteData,
            subtitle: 'Alle Gespräche und Daten löschen',
            onTap: () {},
            danger: true,
          ),

          const SizedBox(height: 24),

          // About
          _SectionHeader('Info'),
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: 'Version',
            subtitle: '1.0.0 (MVP)',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Logout
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: clear tokens & navigate to auth
                context.go('/auth');
              },
              child: Text(
                l.settingsLogout,
                style: OrkaTypography.labelLarge.copyWith(color: OrkaColors.error),
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'de': return 'Deutsch';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      default: return code;
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OrkaColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final current = ref.read(localeProvider).languageCode;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: OrkaColors.borderDark, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Sprache wählen', style: OrkaTypography.headlineSmall.copyWith(color: Colors.white)),
              const SizedBox(height: 20),
              ...['de', 'en', 'ar'].map((code) {
                final isSelected = code == current;
                return ListTile(
                  leading: Text(_flagEmoji(code), style: const TextStyle(fontSize: 24)),
                  title: Text(_languageLabel(code), style: OrkaTypography.bodyMedium.copyWith(color: Colors.white)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: OrkaColors.primary, size: 20) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(Locale(code));
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _flagEmoji(String code) {
    switch (code) {
      case 'de': return '🇩🇪';
      case 'en': return '🇬🇧';
      case 'ar': return '🇸🇦';
      default: return '🌐';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: OrkaTypography.labelSmall.copyWith(color: OrkaColors.textTertiaryDark, letterSpacing: 1)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool danger;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (danger ? OrkaColors.error : OrkaColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: danger ? OrkaColors.error : OrkaColors.primary),
        ),
        title: Text(title, style: OrkaTypography.bodyMedium.copyWith(color: danger ? OrkaColors.error : Colors.white)),
        subtitle: Text(subtitle, style: OrkaTypography.labelSmall.copyWith(color: OrkaColors.textTertiaryDark)),
        trailing: trailing ?? Icon(Iconsax.arrow_right_3, size: 16, color: OrkaColors.textTertiaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onTap,
      ),
    );
  }
}
