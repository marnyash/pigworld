import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/auth/presentation/services/google_sign_in_service.dart';

void main() {
  test('uses the configured Pig World Firebase web client by default', () {
    expect(
      GoogleSignInService.webClientId,
      '279793601563-eh6fs875qbn6c2gvkfk29frcuqe754ri.apps.googleusercontent.com',
    );
    expect(
      () => GoogleSignInService.validateConfiguration(
        GoogleSignInService.webClientId,
      ),
      returnsNormally,
    );
  });

  test('invalid Google web client id still raises a configuration error', () {
    expect(
      () => GoogleSignInService.validateConfiguration('not-a-google-client-id'),
      throwsA(isA<GoogleSignInConfigurationException>()),
    );
  });

  test('valid Google web client id is accepted', () {
    expect(
      () => GoogleSignInService.validateConfiguration(
        '1234567890-abc.apps.googleusercontent.com',
      ),
      returnsNormally,
    );
  });
}
