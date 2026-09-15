import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';
import '../services/google_sign_in_service.dart';
import '../widgets/login_form.dart';
import '../widgets/server_settings_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          tooltip: 'Server address',
          icon: const Icon(Icons.settings_ethernet),
          onPressed: () => showServerSettingsDialog(context, ref),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.jpeg', height: 96),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Sign in to manage your Pig World farm.'),
                const SizedBox(height: 24),
                LoginForm(
                  onSubmit: (identifier, password, rememberMe) async {
                    if (identifier.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter your email and password.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final session = await ref.read(loginUseCaseProvider)(
                        identifier,
                        password,
                        rememberMe: rememberMe,
                      );
                      await ref
                          .read(authServiceProvider)
                          .setRememberMe(rememberMe);
                      await ref.read(sessionManagerProvider).markActive();
                      ref.read(authProvider.notifier).setSession(session);

                      final email = session.user.email.trim();
                      final isDemoLogin =
                          identifier.trim().toLowerCase() == 'test@gmail.com' &&
                          password == 'password';

                      if (isDemoLogin || email.isEmpty) {
                        if (context.mounted) context.go(AppRoutes.home);
                        return;
                      }

                      try {
                        await ref.read(forgotPasswordUseCaseProvider)(email);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'OTP code sent to your registered email.',
                              ),
                            ),
                          );
                          context.go(
                            '${AppRoutes.otpVerification}?email=${Uri.encodeComponent(email)}',
                          );
                        }
                        return;
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Login succeeded, but the OTP could not be sent. Please try again.',
                              ),
                            ),
                          );
                        }
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to sign in. Please check your credentials and try again.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: defaultTargetPlatform == TargetPlatform.iOS
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Continue with Apple is coming soon.',
                            ),
                          ),
                        )
                      : () async {
                          try {
                            final idToken = await GoogleSignInService()
                                .signIn();
                            final session = await ref.read(
                              loginWithGoogleUseCaseProvider,
                            )(idToken);
                            await ref
                                .read(authServiceProvider)
                                .setRememberMe(true);
                            await ref.read(sessionManagerProvider).markActive();
                            ref.read(authProvider.notifier).setSession(session);
                            if (context.mounted) context.go(AppRoutes.home);
                          } on GoogleSignInConfigurationException catch (
                            error
                          ) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.message.isNotEmpty
                                        ? error.message
                                        : 'Google sign-in is not configured for this app yet.',
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Google sign-in could not be completed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  icon: Icon(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? Icons.apple
                        : Icons.g_mobiledata,
                  ),
                  label: Text(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? 'Continue with Apple'
                        : 'Continue with Google',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('New to Pig World?'),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.createAccount),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
