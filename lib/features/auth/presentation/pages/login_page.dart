import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../security/authorization/roles.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/biometric_button.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Image.asset('assets/images/logo.jpeg', height: 96),
          const SizedBox(height: 24),
          Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Sign in to manage your Pig World farm.'),
          const SizedBox(height: 24),
          LoginForm(onSubmit: (email, password, rememberMe) async {
            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email and password.')));
              return;
            }
            final selectedRoles = ref.read(onboardingProvider).roles;
            final role = selectedRoles.contains(UserRole.farmOwner)
                ? UserRole.farmOwner
                : selectedRoles.contains(UserRole.farmManager)
                    ? UserRole.farmManager
                    : UserRole.farmWorker;
            ref.read(authProvider.notifier).setSession(Session(
              accessToken: 'demo-access-token',
              refreshToken: 'demo-refresh-token',
              user: User(id: 'demo-user', name: role == UserRole.farmOwner ? 'Farm owner' : role == UserRole.farmWorker ? 'Farm worker' : 'Farm manager', email: email, role: role),
              farms: const [
                Farm(id: 'green-valley', name: 'Green Valley Farm', location: 'Lancashire, UK'),
                Farm(id: 'sunrise-acres', name: 'Sunrise Acres', location: 'Yorkshire, UK'),
              ],
            ));
            if (context.mounted) {
              context.go(role == UserRole.farmManager && !selectedRoles.contains(UserRole.farmOwner) ? AppRoutes.managerIdentity : AppRoutes.farmSelection);
            }
          }),
          const SizedBox(height: 12),
          BiometricButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric sign-in is not available yet.')))),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go(AppRoutes.forgotPassword), child: const Text('Forgot password?')),
          Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('New to Pig World?'), TextButton(onPressed: () => context.go(AppRoutes.createAccount), child: const Text('Create account'))]),
        ]))))),
      );
}
