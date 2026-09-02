import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../data/settings_local_data_source.dart';
import '../../domain/entities/backup_settings.dart';
import '../../domain/entities/device_settings.dart';
import '../../domain/entities/payment_settings.dart';
import '../../domain/entities/security_settings.dart';
import '../../domain/entities/user_preferences.dart';

// Local data source provider
final settingsLocalDataSourceProvider = Provider(
  (_) => SettingsLocalDataSource(),
);

// User Preferences Provider
class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final local = ref.watch(settingsLocalDataSourceProvider);
    return local.readPreferences();
  }

  Future<void> updateLanguage(String language) async {
    final current = await future;
    final updated = current.copyWith(language: language);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }

  Future<void> updateTheme(bool isDarkMode) async {
    final current = await future;
    final updated = current.copyWith(isDarkMode: isDarkMode);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }

  Future<void> updateWeightUnit(String weightUnit) async {
    final current = await future;
    final updated = current.copyWith(weightUnit: weightUnit);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }

  Future<void> updateDateFormat(String dateFormat) async {
    final current = await future;
    final updated = current.copyWith(dateFormat: dateFormat);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }

  Future<void> updateCurrency(String currency) async {
    final current = await future;
    final updated = current.copyWith(currency: currency);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }

  Future<void> updateNotificationToggle(
    String notificationType,
    bool enabled,
  ) async {
    final current = await future;
    final notifications = {...current.notifications};
    notifications[notificationType] = enabled;
    final updated = current.copyWith(notifications: notifications);
    await ref.watch(settingsLocalDataSourceProvider).savePreferences(updated);
    ref.invalidateSelf();
  }
}

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );

// Security Settings Provider
class SecuritySettingsNotifier extends AsyncNotifier<SecuritySettings> {
  @override
  Future<SecuritySettings> build() async {
    final local = ref.watch(settingsLocalDataSourceProvider);
    return local.readSecuritySettings();
  }

  Future<void> updateTwoFactorAuth(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(hasTwoFactorAuth: enabled);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveSecuritySettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateBiometric(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(hasBiometricEnabled: enabled);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveSecuritySettings(updated);
    ref.invalidateSelf();
  }
}

final securitySettingsProvider =
    AsyncNotifierProvider<SecuritySettingsNotifier, SecuritySettings>(
      SecuritySettingsNotifier.new,
    );

// Backup Settings Provider
class BackupSettingsNotifier extends AsyncNotifier<BackupSettings> {
  @override
  Future<BackupSettings> build() async {
    final local = ref.watch(settingsLocalDataSourceProvider);
    return local.readBackupSettings();
  }

  Future<void> updateCloudSync(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(cloudSyncEnabled: enabled);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveBackupSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateAutoBackup(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(automaticBackupEnabled: enabled);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveBackupSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateBackupFrequency(String frequency) async {
    final current = await future;
    final updated = current.copyWith(backupFrequency: frequency);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveBackupSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateOfflineMode(bool enabled) async {
    final current = await future;
    final updated = current.copyWith(offlineModeEnabled: enabled);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .saveBackupSettings(updated);
    ref.invalidateSelf();
  }
}

final backupSettingsProvider =
    AsyncNotifierProvider<BackupSettingsNotifier, BackupSettings>(
      BackupSettingsNotifier.new,
    );

// Payment Settings Provider
class PaymentSettingsNotifier extends AsyncNotifier<PaymentSettings> {
  @override
  Future<PaymentSettings> build() async {
    final local = ref.watch(settingsLocalDataSourceProvider);
    return local.readPaymentSettings();
  }

  Future<void> updateMPesaNumber(String? number) async {
    final current = await future;
    final updated = current.copyWith(mPesaNumber: number);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .savePaymentSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateBankAccount(String? account) async {
    final current = await future;
    final updated = current.copyWith(bankAccount: account);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .savePaymentSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateBankName(String? name) async {
    final current = await future;
    final updated = current.copyWith(bankName: name);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .savePaymentSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateTaxRate(double rate) async {
    final current = await future;
    final updated = current.copyWith(taxRate: rate);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .savePaymentSettings(updated);
    ref.invalidateSelf();
  }

  Future<void> updateVAT(double vat) async {
    final current = await future;
    final updated = current.copyWith(vat: vat);
    await ref
        .watch(settingsLocalDataSourceProvider)
        .savePaymentSettings(updated);
    ref.invalidateSelf();
  }
}

final paymentSettingsProvider =
    AsyncNotifierProvider<PaymentSettingsNotifier, PaymentSettings>(
      PaymentSettingsNotifier.new,
    );

// Device Settings Provider
final deviceSettingsProvider =
    AsyncNotifierProvider<AsyncNotifier<DeviceSettings>, DeviceSettings>(
      () => throw UnimplementedError(),
    );

// Theme Provider (for theme switching at app level)
final appThemeProvider = StateProvider<bool>((ref) {
  return ref.watch(userPreferencesProvider).valueOrNull?.isDarkMode ?? false;
});

// Language Provider (for i18n at app level)
final appLanguageProvider = StateProvider<String>((ref) {
  return ref.watch(userPreferencesProvider).valueOrNull?.language ?? 'en';
});

// Helper to get display text for settings options
class SettingsHelper {
  static String getLanguageName(String code) {
    return const {'en': 'English', 'sw': 'Kiswahili'}[code] ?? code;
  }

  static String getWeightUnitName(String unit) {
    return const {'kg': 'Kilograms (kg)', 'lb': 'Pounds (lb)'}[unit] ?? unit;
  }

  static String getCurrencyName(String code) {
    return const {
          'KES': 'Kenyan Shilling (KES)',
          'USD': 'US Dollar (USD)',
        }[code] ??
        code;
  }

  static String getDateFormatName(String format) {
    return const {
          'dd/MM/yyyy': 'DD/MM/YYYY',
          'MM/dd/yyyy': 'MM/DD/YYYY',
          'yyyy-MM-dd': 'YYYY-MM-DD',
        }[format] ??
        format;
  }

  static String getNotificationName(String type) {
    return const {
          'vaccinations': 'Vaccination Reminders',
          'feeding': 'Feeding Reminders',
          'breeding': 'Breeding Alerts',
          'lowStock': 'Low Stock Alerts',
          'sales': 'Sales Notifications',
          'payments': 'Payment Notifications',
        }[type] ??
        type;
  }

  static String getBackupFrequencyName(String frequency) {
    return const {
          'daily': 'Daily',
          'weekly': 'Weekly',
          'monthly': 'Monthly',
        }[frequency] ??
        frequency;
  }

  static String getDeviceTypeName(String type) {
    return const {
          'rfidScanner': 'RFID Scanner',
          'weighingScale': 'Weighing Scale',
          'gpsTracker': 'GPS Tracker',
          'camera': 'Camera',
        }[type] ??
        type;
  }

  static IconData getDeviceTypeIcon(String type) {
    return const {
          'rfidScanner': Icons.nfc,
          'weighingScale': Icons.scale,
          'gpsTracker': Icons.location_on,
          'camera': Icons.camera_alt,
        }[type] ??
        Icons.devices;
  }
}
