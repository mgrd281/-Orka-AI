/// Orka AI — App Router (go_router)
///
/// Clean navigation architecture with auth guards.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/conversation_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const AuthScreen(isRegister: true),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/chat/:id',
            builder: (context, state) => ConversationScreen(
              conversationId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
        ],
      ),
    ],
  );
});
