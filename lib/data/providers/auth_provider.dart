import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _user;
  bool _isLoading = false;
  String? _error;

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _user!.id.isNotEmpty;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      _user = UserProfile.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final accounts = jsonDecode(prefs.getString('safebite_accounts') ?? '{}') as Map<String, dynamic>;
    final account = accounts[email.toLowerCase()];
    if (account == null || account['passwordHash'] != sha256.convert(utf8.encode(password)).toString()) {
      _error = 'Email or password is incorrect.';
      _isLoading = false; notifyListeners(); return false;
    }
    _user = UserProfile.fromJson(Map<String, dynamic>.from(account['profile']));
    await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
    _isLoading = false; notifyListeners(); return true;
  }

  Future<bool> signUp(String name, int age, String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final accounts = jsonDecode(prefs.getString('safebite_accounts') ?? '{}') as Map<String, dynamic>;
    final key = email.toLowerCase();
    if (accounts.containsKey(key)) {
      _error = 'An account with this email already exists.';
      _isLoading = false; notifyListeners(); return false;
    }
    final profile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name, age: age, email: email,
    );
    accounts[key] = {'passwordHash': sha256.convert(utf8.encode(password)).toString(), 'profile': profile.toJson()};
    await prefs.setString('safebite_accounts', jsonEncode(accounts));
    _user = profile;
    await prefs.setString(AppConstants.userKey, jsonEncode(profile.toJson()));
    _isLoading = false; notifyListeners(); return true;
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    _user = UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User', email: '', isGuest: true,
    );
    await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _user = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.tokenKey);
    _user = null;
    notifyListeners();
  }
}
