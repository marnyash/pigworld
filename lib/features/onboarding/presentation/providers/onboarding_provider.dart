import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  const OnboardingState({this.notifications = false, this.location = false, this.language = 'English', this.country});

  final bool notifications;
  final bool location;
  final String language;
  final String? country;

  OnboardingState copyWith({bool? notifications, bool? location, String? language, String? country}) => OnboardingState(
        notifications: notifications ?? this.notifications,
        location: location ?? this.location,
        language: language ?? this.language,
        country: country ?? this.country,
      );
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setPermissions({required bool notifications, required bool location}) => state = state.copyWith(notifications: notifications, location: location);
  void setLanguage(String language) => state = state.copyWith(language: language);
  void setCountry(String country) => state = state.copyWith(country: country);
}