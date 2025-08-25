import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  static const String _syncEnabledKey = 'sync_enabled';

  Future<bool> getSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncEnabledKey) ?? false;
  }

  Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncEnabledKey, enabled);
  }
}