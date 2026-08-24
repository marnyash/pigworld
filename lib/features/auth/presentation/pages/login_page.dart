import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../security/authorization/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                const SizedBox(height: 8),
                // TODO(temporary): remove once backend auth is available.
                const Text(
                  'Demo login: demo@gmail.com / testpassword',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                const SizedBox(height: 24),
                LoginForm(
                  onSubmit: (email, password, rememberMe) async {
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter your email and password.'),
                        ),
                      );
                      return;
                    }
                    final session = await ref.read(loginUseCaseProvider)(
                      email,
                      password,
                      rememberMe: rememberMe,
                    );
                    ref.read(authProvider.notifier).setSession(session);
                    if (context.mounted) {
                      context.go(
                        session.user.role == UserRole.farmManager
                            ? AppRoutes.managerIdentity
                            : AppRoutes.home,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        defaultTargetPlatform == TargetPlatform.iOS
                            ? 'Continue with Apple will be connected soon.'
                            : 'Continue with Google will be connected soon.',
                      ),
                    ),
                  ),
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
