import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/session.dart';
import '../providers/auth_provider.dart';
import '../../../settings/presentation/providers/farm_access_provider.dart';

class ManagerIdentityPage extends ConsumerStatefulWidget {
  const ManagerIdentityPage({super.key});

  @override
  ConsumerState<ManagerIdentityPage> createState() => _ManagerIdentityPageState();
}

class _ManagerIdentityPageState extends ConsumerState<ManagerIdentityPage> {
  final controller = TextEditingController();
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Connect to a farm owner')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Icon(Icons.link, size: 56),
          const SizedBox(height: 20),
          Text('Enter the identity number shared by your farm owner.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('This connects your account to the right farm and applies the policies your owner has granted you.'),
          const SizedBox(height: 24),
          TextField(controller: controller, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: 'Owner identity number', errorText: error)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              ref.read(farmAccessProvider.notifier).connectManager(controller.text);
              if (!ref.read(farmAccessProvider).connectedOwner) {
                setState(() => error = 'That identity number was not found.');
                return;
              }
              final session = ref.read(authProvider).valueOrNull;
              if (session != null && session.farms.isNotEmpty) {
                ref.read(authProvider.notifier).setSession(Session(
                  accessToken: session.accessToken,
                  refreshToken: session.refreshToken,
                  user: session.user,
                  farms: session.farms,
                  selectedFarm: session.farms.first,
                ));
              }
              context.go(AppRoutes.home);
            },
            child: const Text('Connect farm'),
          ),
        ]),
      );
}