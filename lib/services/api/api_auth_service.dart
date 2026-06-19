import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import '../auth_service.dart';
import 'api_client.dart';

const String _kTokenKey = 'api_auth.token';

/// Implementasi [AuthService] yang berbicara dengan backend FastAPI.
class ApiAuthService implements AuthService {
  ApiAuthService(this._api) {
    _ctrl = StreamController<AppUser?>.broadcast(
      onListen: () => _ctrl.add(_currentUser),
    );
  }

  final ApiClient _api;
  late final StreamController<AppUser?> _ctrl;
  AppUser? _currentUser;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async =>
      _prefs ??= await SharedPreferences.getInstance();

  AppUser _parseUser(Map<String, dynamic> map) =>
      AppUser.fromMap(map['id'] as String, map);

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _ctrl.stream;

  @override
  Future<void> init() async {
    final prefs = await _sp;
    final token = prefs.getString(_kTokenKey);
    if (token == null) return;
    _api.token = token;
    try {
      final me = await _api.get('/api/auth/me') as Map<String, dynamic>;
      _currentUser = _parseUser(me);
      _ctrl.add(_currentUser);
    } catch (_) {
      // Token kedaluwarsa / tidak valid — bersihkan sesi.
      _api.token = null;
      await prefs.remove(_kTokenKey);
    }
  }

  Future<void> _applySession(Map<String, dynamic> res) async {
    final token = res['token'] as String;
    final user = _parseUser(res['user'] as Map<String, dynamic>);
    _api.token = token;
    _currentUser = user;
    (await _sp).setString(_kTokenKey, token);
    _ctrl.add(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;
    await _applySession(res);
    return _currentUser!;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required AppUser profile,
  }) async {
    final res = await _api.post('/api/auth/register', {
      'id': profile.id,
      'email': email.trim(),
      'password': password,
      'name': name,
      'profile': profile.toMap(),
    }) as Map<String, dynamic>;
    await _applySession(res);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _api.token = null;
    (await _sp).remove(_kTokenKey);
    _ctrl.add(null);
  }

  @override
  Future<AppUser> updateProfile(AppUser updated) async {
    if (_currentUser == null || updated.id != _currentUser!.id) {
      throw Exception('Tidak ada sesi pengguna aktif');
    }
    final res = await _api.put('/api/auth/profile', {
      'id': updated.id,
      'profile': updated.toMap(),
    }) as Map<String, dynamic>;
    _currentUser = _parseUser(res);
    _ctrl.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
