import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/auth/domain/entities/farm.dart';
import 'package:proj/features/auth/domain/entities/session.dart';
import 'package:proj/features/auth/domain/entities/user.dart';
import 'package:proj/features/auth/presentation/providers/auth_provider.dart';
import 'package:proj/features/health/presentation/providers/health_providers.dart';
import 'package:proj/features/herd/data/herd_api.dart';
import 'package:proj/features/herd/domain/entities/animal.dart';
import 'package:proj/features/herd/presentation/pages/herd_page.dart';
import 'package:proj/features/herd/presentation/providers/herd_provider.dart';
import 'package:proj/l10n/generated/app_localizations.dart';
import 'package:proj/security/authorization/roles.dart';

void main() {
  testWidgets('adding a sow persists and refreshes the farm herd', (
    WidgetTester tester,
  ) async {
    final api = _FakeHerdApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
          herdApiProvider.overrideWithValue(api),
          healthOverviewProvider.overrideWith((ref) async => {'vaccinated': 0}),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HerdPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Pig'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'PIG-NEW');
    await tester.tap(find.text('Add sow').last);
    await tester.pumpAndSettle();

    expect(api.createdTags, ['PIG-NEW']);
    expect(find.text('PIG-NEW'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AsyncValue<Session?> build() => AsyncData(
    Session(
      accessToken: 'access',
      refreshToken: 'refresh',
      user: const User(
        id: 'user-1',
        name: 'Test User',
        email: 'test@example.com',
        role: UserRole.farmOwner,
      ),
      farms: const [Farm(id: 'farm-1', name: 'Test Farm')],
      selectedFarm: const Farm(id: 'farm-1', name: 'Test Farm'),
    ),
  );
}

class _FakeHerdApi extends HerdApi {
  _FakeHerdApi() : super(Dio());

  final List<Animal> _animals = [];
  final List<String> createdTags = [];
  var _nextId = 1;

  @override
  Future<List<Animal>> fetchAnimals(String farmId) async => List.of(_animals);

  @override
  Future<Animal> createSow({
    required String farmId,
    required String tag,
    DateTime? birthDate,
    String? notes,
  }) async {
    createdTags.add(tag);
    final animal = Animal(
      id: 'animal-${_nextId++}',
      tag: tag,
      type: 'sow',
      sex: 'female',
      status: 'active',
      birthDate: birthDate,
      notes: notes,
    );
    _animals.add(animal);
    return animal;
  }
}
