import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Local storage service for non-sensitive user preferences.
/// For sensitive data (tokens, credentials) use [SecureStorageService].
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'StorageService.initialize() must be called before use.');
    return _prefs!;
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  Future<void> setThemeMode(String mode) => _p.setString(AppConstants.keyThemeMode, mode);
  String? getThemeMode() => _p.getString(AppConstants.keyThemeMode);

  // ── Language ──────────────────────────────────────────────────────────────

  Future<void> setLanguage(String langCode) => _p.setString(AppConstants.keyLanguage, langCode);
  String getLanguage() => _p.getString(AppConstants.keyLanguage) ?? 'en';

  // ── Onboarding ────────────────────────────────────────────────────────────

  Future<void> setOnboardingDone() => _p.setBool(AppConstants.keyOnboardingDone, true);
  bool isOnboardingDone() => _p.getBool(AppConstants.keyOnboardingDone) ?? false;

  // ── Generic ───────────────────────────────────────────────────────────────

  Future<bool> setString(String key, String value) => _p.setString(key, value);
  String? getString(String key) => _p.getString(key);

  Future<bool> setBool(String key, bool value) => _p.setBool(key, value);
  bool? getBool(String key) => _p.getBool(key);

  Future<bool> setInt(String key, int value) => _p.setInt(key, value);
  int? getInt(String key) => _p.getInt(key);

  Future<bool> remove(String key) => _p.remove(key);

  Future<bool> clear() => _p.clear();
}

/// Secure storage service interface — wire to flutter_secure_storage when ready.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  // TODO: inject FlutterSecureStorage instance here.
  // final _storage = const FlutterSecureStorage(
  //   aOptions: AndroidOptions(encryptedSharedPreferences: true),
  //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  // );

  Future<void> write({required String key, required String value}) async {
    // await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    // return await _storage.read(key: key);
    return null;
  }

  Future<void> delete({required String key}) async {
    // await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    // await _storage.deleteAll();
  }
}
