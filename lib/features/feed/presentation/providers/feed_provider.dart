import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/feed_api.dart';
import '../../data/feed_schedule_local_data_source.dart';

final feedScheduleStorageProvider = Provider(
  (_) => FeedScheduleLocalDataSource(),
);

final feedScheduleProvider =
    AsyncNotifierProvider<FeedScheduleNotifier, Map<String, bool>>(
      FeedScheduleNotifier.new,
    );

class FeedScheduleNotifier extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() async {
    final session = ref.watch(authProvider).valueOrNull;
    final farm = session?.selectedFarm;
    final user = session?.user;
    if (farm == null || user == null)
      return FeedScheduleLocalDataSource.defaults;
    return ref
        .watch(feedScheduleStorageProvider)
        .read(userId: user.id, farmId: farm.id);
  }

  Future<void> setCompleted(String name, bool completed) async {
    if (!FeedScheduleLocalDataSource.defaults.containsKey(name)) {
      throw ArgumentError.value(name, 'name', 'Unknown feeding time');
    }
    final session = ref.read(authProvider).valueOrNull;
    final farm = session?.selectedFarm;
    final user = session?.user;
    if (farm == null || user == null) throw StateError('No farm selected.');

    final previous = state.valueOrNull ?? FeedScheduleLocalDataSource.defaults;
    final updated = {...previous, name: completed};
    state = AsyncData(updated);
    try {
      await ref
          .read(feedScheduleStorageProvider)
          .write(userId: user.id, farmId: farm.id, completed: updated);
    } on Object {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final feedApiProvider = Provider<FeedApi>(
  (ref) => FeedApi(ref.watch(dioProvider)),
);
final feedProvider = AsyncNotifierProvider<FeedNotifier, FeedSnapshot>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<FeedSnapshot> {
  @override
  Future<FeedSnapshot> build() async {
    final farmId = ref.watch(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) return const FeedSnapshot(stock: [], usage: []);
    return ref.watch(feedApiProvider).fetch(farmId);
  }

  Future<void> addStock({
    required String name,
    required double quantity,
    required String unit,
    double? unitCost,
    String? location,
  }) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');
    await ref
        .read(feedApiProvider)
        .addStock(
          farmId: farmId,
          name: name,
          quantity: quantity,
          unit: unit,
          unitCost: unitCost,
          location: location,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> recordUsage({
    String? stockId,
    required double quantity,
    required String unit,
    required DateTime usedAt,
    String? notes,
  }) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');
    await ref
        .read(feedApiProvider)
        .recordUsage(
          farmId: farmId,
          stockId: stockId,
          quantity: quantity,
          unit: unit,
          usedAt: usedAt,
          notes: notes,
        );
    ref.invalidateSelf();
    await future;
  }
}
