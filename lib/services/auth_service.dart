import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUsername = 'logged_in_username';
  static const String validUsername = '124240132';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername) ?? '';
  }

  static Future<bool> login(String username, String password) async {
    final normalizedUsername = username.trim();

    if (normalizedUsername == validUsername && password == '123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyIsLoggedIn, true);
      await prefs.setString(keyUsername, normalizedUsername);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUsername);
  }
}
