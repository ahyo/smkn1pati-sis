import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _user = _service.currentUser;
    _sub = _service.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  final AuthService _service;
  StreamSubscription<AppUser?>? _sub;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _busy = false;
  bool get busy => _busy;

  Future<bool> signIn(String email, String password) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _service.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required AppUser profile,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _service.register(
        email: email,
        password: password,
        name: name,
        profile: profile,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  Future<bool> updateProfile(AppUser updated) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final saved = await _service.updateProfile(updated);
      _user = saved;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
