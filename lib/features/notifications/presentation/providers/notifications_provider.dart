import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/notifications_api.dart';

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(dioProvider)),
);

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<FarmNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends AsyncNotifier<List<FarmNotification>> {
  @override
  Future<List<FarmNotification>> build() async {
    final farmId = ref.watch(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) return const [];
    return ref.watch(notificationsApiProvider).fetch(farmId);
  }

  Future<void> markAsRead(String notificationId) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');

    final updated = await ref
        .read(notificationsApiProvider)
        .markAsRead(farmId: farmId, notificationId: notificationId);
    final notifications = state.valueOrNull;
    if (notifications == null) return;
    state = AsyncData([
      for (final notification in notifications)
        notification.id == updated.id ? updated : notification,
    ]);
  }
}
