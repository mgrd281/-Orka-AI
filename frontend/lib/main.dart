import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OrkaAIApp()));
}

class OrkaAIApp extends ConsumerWidget {
  const OrkaAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Orka AI',
      debugShowCheckedModeBanner: false,
      theme: OrkaTheme.light,
      darkTheme: OrkaTheme.dark,
      themeMode: ThemeMode.dark, // Default to dark mode
      locale: locale,
      supportedLocales: const [
        Locale('de'), // German (default)
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
