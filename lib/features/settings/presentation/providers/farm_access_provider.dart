import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../domain/entities/farm_member.dart';

final farmAccessProvider = NotifierProvider<FarmAccessNotifier, FarmAccessState>(FarmAccessNotifier.new);

class FarmAccessState {
  const FarmAccessState({
    required this.members,
    this.connectedOwner = false,
    this.managerCanAddWorkers = false,
  });

  final List<FarmMember> members;
  final bool connectedOwner;
  final bool managerCanAddWorkers;

  FarmAccessState copyWith({List<FarmMember>? members, bool? connectedOwner, bool? managerCanAddWorkers}) => FarmAccessState(
        members: members ?? this.members,
        connectedOwner: connectedOwner ?? this.connectedOwner,
        managerCanAddWorkers: managerCanAddWorkers ?? this.managerCanAddWorkers,
      );
}

class FarmAccessNotifier extends Notifier<FarmAccessState> {
  @override
  FarmAccessState build() => const FarmAccessState(members: [
        FarmMember(
          id: 'owner-1',
          name: 'Amina Otieno',
          email: 'amina@greenvalley.farm',
          role: UserRole.farmOwner,
          identityNumber: 'KE-OWNER-1042',
        ),
        FarmMember(
          id: 'manager-1',
          name: 'Farm manager',
          email: 'manager@pigworld.farm',
          role: UserRole.farmManager,
          identityNumber: 'KE-MGR-2048',
          permissions: {AppPermission.manageMembers},
        ),
      ], connectedOwner: true, managerCanAddWorkers: true);

  void connectManager(String identityNumber) {
    if (identityNumber.trim().toUpperCase() == 'KE-OWNER-1042') {
      state = state.copyWith(connectedOwner: true);
    }
  }

  void setManagerCanAddWorkers(bool allowed) {
    state = state.copyWith(
      managerCanAddWorkers: allowed,
      members: [
        for (final member in state.members)
          member.role == UserRole.farmManager
              ? member.copyWith(permissions: allowed ? {...member.permissions, AppPermission.manageMembers} : member.permissions.difference({AppPermission.manageMembers}))
              : member,
      ],
    );
  }

  void addMember({required String name, required String email, required UserRole role, required String identityNumber}) {
    final member = FarmMember(id: '${role.name}-${state.members.length}', name: name, email: email, role: role, identityNumber: identityNumber);
    state = state.copyWith(members: [...state.members, member]);
  }

  void togglePermission(String memberId, AppPermission permission, bool allowed) {
    if (permission == AppPermission.manageMembers) state = state.copyWith(managerCanAddWorkers: allowed);
    state = state.copyWith(members: [
      for (final member in state.members)
        if (member.id == memberId)
          member.copyWith(permissions: allowed ? {...member.permissions, permission} : member.permissions.difference({permission}))
        else
          member,
    ]);
  }

  bool canManageMembers(UserRole role) => role == UserRole.farmOwner || (role == UserRole.farmManager && state.managerCanAddWorkers);
}