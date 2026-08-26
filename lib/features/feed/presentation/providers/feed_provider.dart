import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/feed_api.dart';

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
