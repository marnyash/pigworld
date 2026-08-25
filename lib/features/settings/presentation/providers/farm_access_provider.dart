import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/farm_members_api.dart';
import '../../domain/entities/farm_member.dart';

final farmMembersApiProvider = Provider<FarmMembersApi>((ref) => FarmMembersApi(ref.watch(dioProvider)));

final farmAccessProvider = AsyncNotifierProvider<FarmAccessNotifier, FarmAccessState>(FarmAccessNotifier.new);

class FarmAccessState {
  const FarmAccessState({required this.members});

  final List<FarmMember> members;

  /// The effective permissions for a member: the farm owner's overrides, or their role's defaults.
  Set<AppPermission> permissionsFor(String userId) {
    for (final member in members) {
      if (member.id == userId) return member.permissions;
    }
    return const {};
  }
}

class FarmAccessNotifier extends AsyncNotifier<FarmAccessState> {
  @override
  Future<FarmAccessState> build() async {
    final farmId = ref.watch(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) return const FarmAccessState(members: []);
    final members = await ref.watch(farmMembersApiProvider).fetchMembers(farmId);
    return FarmAccessState(members: members);
  }

  Future<void> togglePermission(String memberId, AppPermission permission, bool allowed) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    final current = state.valueOrNull;
    if (farmId == null || current == null) return;

    final member = current.members.firstWhere((member) => member.id == memberId);
    final updatedPermissions = allowed ? {...member.permissions, permission} : member.permissions.difference({permission});

    state = AsyncData(FarmAccessState(members: [
      for (final existing in current.members)
        existing.id == memberId ? existing.copyWith(permissions: updatedPermissions) : existing,
    ]));

    try {
      await ref.read(farmMembersApiProvider).updatePermissions(farmId, memberId, updatedPermissions);
    } catch (_) {
      // Roll back optimistic update on failure by refetching from the server.
      state = AsyncData(current);
      ref.invalidateSelf();
    }
  }

  bool canManageMembers(UserRole role) {
    if (role == UserRole.farmOwner) return true;
    final myId = ref.read(authProvider).valueOrNull?.user.id;
    if (role != UserRole.farmManager || myId == null) return false;
    return state.valueOrNull?.permissionsFor(myId).contains(AppPermission.manageMembers) ?? false;
  }
}
