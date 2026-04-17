/// Orka AI — Auth Screen
///
/// Premium login/register with social auth options.
/// Elegant form with smooth transitions.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/api_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isRegister;

  const AuthScreen({super.key, this.isRegister = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isRegister;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.isRegister;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Bitte alle Felder ausfüllen');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      if (_isRegister) {
        await api.register(
          email: email,
          password: password,
          fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        );
      } else {
        await api.login(email: email, password: password);
      }

      if (mounted) context.go('/chat');
    } catch (e) {
      setState(() => _error = 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: OrkaColors.surfaceDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo & Title
              Center(
                child: Column(
                  children: [
                    // Orka Logo Mark
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: OrkaColors.premiumGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: OrkaColors.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Orka AI',
                      style: OrkaTypography.displayMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Koordinierte Intelligenz',
                      style: OrkaTypography.bodyMedium.copyWith(
                        color: OrkaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

              const SizedBox(height: 48),

              // Form title
              Text(
                _isRegister ? l.authRegister : l.authLogin,
                style: OrkaTypography.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Name field (register only)
              if (_isRegister) ...[
                TextField(
                  controller: _nameController,
                  style: OrkaTypography.bodyMedium.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l.authFullName,
                    prefixIcon: const Icon(Iconsax.user, size: 20, color: OrkaColors.textTertiaryDark),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: OrkaTypography.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l.authEmail,
                  prefixIcon: const Icon(Iconsax.sms, size: 20, color: OrkaColors.textTertiaryDark),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: OrkaTypography.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l.authPassword,
                  prefixIcon: const Icon(Iconsax.lock, size: 20, color: OrkaColors.textTertiaryDark),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                      size: 20,
                      color: OrkaColors.textTertiaryDark,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: OrkaTypography.bodySmall.copyWith(color: OrkaColors.error),
                ),
              ],

              // Forgot password
              if (!_isRegister) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      l.authForgotPassword,
                      style: OrkaTypography.labelMedium.copyWith(
                        color: OrkaColors.primary,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrkaColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegister ? l.authRegister : l.authLogin,
                          style: OrkaTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: OrkaColors.borderDark)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l.authOrContinueWith,
                      style: OrkaTypography.labelSmall.copyWith(
                        color: OrkaColors.textTertiaryDark,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: OrkaColors.borderDark)),
                ],
              ),

              const SizedBox(height: 24),

              // Social auth buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      icon: Icons.apple_rounded,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Toggle login/register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegister ? l.authHasAccount : l.authNoAccount,
                    style: OrkaTypography.bodySmall.copyWith(
                      color: OrkaColors.textSecondaryDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister ? l.authLogin : l.authRegister,
                      style: OrkaTypography.labelLarge.copyWith(
                        color: OrkaColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: OrkaColors.textPrimaryDark,
          side: const BorderSide(color: OrkaColors.borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
