import 'package:flutter/material.dart';

import 'translations_de.dart';
import 'translations_en.dart';
import 'translations_ar.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'de': translationsDe,
    'en': translationsEn,
    'ar': translationsAr,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['de']?[key] ??
        key;
  }

  // === Convenience Getters ===

  // Navigation
  String get navChat => translate('nav_chat');
  String get navHistory => translate('nav_history');
  String get navDiscover => translate('nav_discover');
  String get navSettings => translate('nav_settings');

  // Onboarding
  String get onboardingTitle1 => translate('onboarding_title_1');
  String get onboardingDesc1 => translate('onboarding_desc_1');
  String get onboardingTitle2 => translate('onboarding_title_2');
  String get onboardingDesc2 => translate('onboarding_desc_2');
  String get onboardingTitle3 => translate('onboarding_title_3');
  String get onboardingDesc3 => translate('onboarding_desc_3');
  String get onboardingGetStarted => translate('onboarding_get_started');
  String get onboardingNext => translate('onboarding_next');
  String get onboardingSkip => translate('onboarding_skip');

  // Auth
  String get authLogin => translate('auth_login');
  String get authRegister => translate('auth_register');
  String get authEmail => translate('auth_email');
  String get authPassword => translate('auth_password');
  String get authFullName => translate('auth_full_name');
  String get authForgotPassword => translate('auth_forgot_password');
  String get authOrContinueWith => translate('auth_or_continue_with');
  String get authGoogle => translate('auth_google');
  String get authApple => translate('auth_apple');
  String get authNoAccount => translate('auth_no_account');
  String get authHasAccount => translate('auth_has_account');

  // Chat
  String get chatNewChat => translate('chat_new_chat');
  String get chatPlaceholder => translate('chat_placeholder');
  String get chatSend => translate('chat_send');
  String get chatThinking => translate('chat_thinking');
  String get chatShowReasoning => translate('chat_show_reasoning');
  String get chatHideReasoning => translate('chat_hide_reasoning');
  String get chatCopy => translate('chat_copy');
  String get chatShare => translate('chat_share');
  String get chatRetry => translate('chat_retry');
  String get chatEmpty => translate('chat_empty');
  String get chatEmptyHint => translate('chat_empty_hint');

  // Modes
  String get modeFast => translate('mode_fast');
  String get modeFastDesc => translate('mode_fast_desc');
  String get modeSmart => translate('mode_smart');
  String get modeSmartDesc => translate('mode_smart_desc');
  String get modeDeep => translate('mode_deep');
  String get modeDeepDesc => translate('mode_deep_desc');

  // Agents
  String get agentAnalyst => translate('agent_analyst');
  String get agentResearcher => translate('agent_researcher');
  String get agentCreative => translate('agent_creative');
  String get agentCritic => translate('agent_critic');
  String get agentSynthesizer => translate('agent_synthesizer');
  String get agentJudge => translate('agent_judge');

  // Settings
  String get settingsTitle => translate('settings_title');
  String get settingsProfile => translate('settings_profile');
  String get settingsLanguage => translate('settings_language');
  String get settingsAppearance => translate('settings_appearance');
  String get settingsDefaultMode => translate('settings_default_mode');
  String get settingsSubscription => translate('settings_subscription');
  String get settingsPrivacy => translate('settings_privacy');
  String get settingsAbout => translate('settings_about');
  String get settingsLogout => translate('settings_logout');
  String get settingsDarkMode => translate('settings_dark_mode');
  String get settingsLightMode => translate('settings_light_mode');
  String get settingsSystemMode => translate('settings_system_mode');

  // Subscription
  String get subFree => translate('sub_free');
  String get subPro => translate('sub_pro');
  String get subPremium => translate('sub_premium');
  String get subUpgrade => translate('sub_upgrade');
  String get subCurrentPlan => translate('sub_current_plan');
  String get subMessagesPerDay => translate('sub_messages_per_day');
  String get subUnlimited => translate('sub_unlimited');

  // Common
  String get commonCancel => translate('common_cancel');
  String get commonSave => translate('common_save');
  String get commonDelete => translate('common_delete');
  String get commonEdit => translate('common_edit');
  String get commonSearch => translate('common_search');
  String get commonLoading => translate('common_loading');
  String get commonError => translate('common_error');
  String get commonRetry => translate('common_retry');
  String get commonDone => translate('common_done');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['de', 'en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
