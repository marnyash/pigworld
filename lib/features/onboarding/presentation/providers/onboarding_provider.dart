import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../security/authorization/roles.dart';

class OnboardingState {
  const OnboardingState({this.notifications = false, this.location = false, this.language = 'English', this.languageCode = 'en', this.country, this.roles = const {}});

  final bool notifications;
  final bool location;
  final String language;
    final String languageCode;
  final String? country;
    final Set<UserRole> roles;

    OnboardingState copyWith({bool? notifications, bool? location, String? language, String? languageCode, String? country, Set<UserRole>? roles}) => OnboardingState(
        notifications: notifications ?? this.notifications,
        location: location ?? this.location,
        language: language ?? this.language,
      languageCode: languageCode ?? this.languageCode,
        country: country ?? this.country,
      roles: roles ?? this.roles,
      );
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setPermissions({required bool notifications, required bool location}) => state = state.copyWith(notifications: notifications, location: location);
  void setLanguage({required String name, required String code}) => state = state.copyWith(language: name, languageCode: code);
  void setCountry(String country) => state = state.copyWith(country: country);
  void toggleRole(UserRole role, bool selected) {
    final roles = {...state.roles};
    selected ? roles.add(role) : roles.remove(role);
    state = state.copyWith(roles: roles);
  }
}