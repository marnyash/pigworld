import 'dart:typed_data';

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
  testWidgets('adding a pig persists and refreshes the farm herd', (
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
    expect(find.text('Male pig'), findsOneWidget);
    expect(find.text('Female pig'), findsOneWidget);
    expect(find.text('Piglet'), findsOneWidget);
    expect(find.text('Add a photo'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'PIG-NEW');
    await tester.enterText(fields.at(1), '45.5');
    await tester.tap(find.text('Add pig').last);
    await tester.pumpAndSettle();

    expect(api.createdTags, ['PIG-NEW']);
    expect(api.createdWeights, [45.5]);
    expect(find.text('PIG-NEW'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing a pig exposes its photo replacement control', (
    WidgetTester tester,
  ) async {
    final api = _FakeHerdApi(
      animals: [
        const Animal(
          id: 'animal-1',
          tag: 'PIG-1',
          type: 'sow',
          sex: 'female',
          status: 'active',
        ),
      ],
    );
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

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Change photo'), findsOneWidget);
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
  _FakeHerdApi({List<Animal> animals = const []})
    : _animals = List.of(animals),
      super(Dio());

  final List<Animal> _animals;
  final List<String> createdTags = [];
  final List<double?> createdWeights = [];
  var _nextId = 1;

  @override
  Future<List<Animal>> fetchAnimals(String farmId) async => List.of(_animals);

  @override
  Future<Animal> createAnimal({
    required String farmId,
    required String tag,
    required String type,
    required String sex,
    DateTime? birthDate,
    double? weightKg,
    String? notes,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    createdTags.add(tag);
    createdWeights.add(weightKg);
    final animal = Animal(
      id: 'animal-${_nextId++}',
      tag: tag,
      type: type,
      sex: sex,
      status: 'active',
      birthDate: birthDate,
      weightKg: weightKg,
      notes: notes,
    );
    _animals.add(animal);
    return animal;
  }
}
