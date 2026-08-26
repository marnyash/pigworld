import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/herd_api.dart';
import '../../domain/entities/animal.dart';

final herdApiProvider = Provider<HerdApi>(
  (ref) => HerdApi(ref.watch(dioProvider)),
);

final herdProvider = AsyncNotifierProvider<HerdNotifier, List<Animal>>(
  HerdNotifier.new,
);

class HerdNotifier extends AsyncNotifier<List<Animal>> {
  @override
  Future<List<Animal>> build() async {
    final farmId = ref.watch(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) return [];
    return ref.watch(herdApiProvider).fetchAnimals(farmId);
  }

  Future<void> createSow({
    required String tag,
    DateTime? birthDate,
    String? notes,
  }) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');
    await ref
        .read(herdApiProvider)
        .createSow(
          farmId: farmId,
          tag: tag,
          birthDate: birthDate,
          notes: notes,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateAnimal({
    required String animalId,
    String? tag,
    String? status,
    DateTime? birthDate,
    String? notes,
  }) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');
    await ref
        .read(herdApiProvider)
        .updateAnimal(
          farmId: farmId,
          animalId: animalId,
          tag: tag,
          status: status,
          birthDate: birthDate,
          notes: notes,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> archiveAnimal(String animalId) async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) throw StateError('No farm selected.');
    await ref
        .read(herdApiProvider)
        .archiveAnimal(farmId: farmId, animalId: animalId);
    ref.invalidateSelf();
    await future;
  }
}
