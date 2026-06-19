import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../auth_service.dart';
import '../device/device_info.dart';
import 'mock_store.dart';

const String _kPersistedUserIdKey = 'mock_auth.current_user_id';

class MockAuthService implements AuthService {
  MockAuthService() {
    _ctrl = StreamController<AppUser?>.broadcast(
      onListen: () => _ctrl.add(_currentUser),
    );
  }

  late final StreamController<AppUser?> _ctrl;
  AppUser? _currentUser;
  SharedPreferences? _prefs;
  static const _uuid = Uuid();

  Future<SharedPreferences> get _sp async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _ctrl.stream;

  @override
  Future<void> init() async {
    final prefs = await _sp;
    final id = prefs.getString(_kPersistedUserIdKey);
    if (id == null) return;
    final user = MockStore.instance.users[id];
    if (user == null) {
      await prefs.remove(_kPersistedUserIdKey);
      return;
    }
    _currentUser = user;
    _ctrl.add(user);
  }

  Future<void> _persist(String? id) async {
    final prefs = await _sp;
    if (id == null) {
      await prefs.remove(_kPersistedUserIdKey);
    } else {
      await prefs.setString(_kPersistedUserIdKey, id);
    }
  }

  void _audit({
    required AuditAction action,
    AppUser? actor,
    String? actorEmailFallback,
    String? targetType,
    String? targetId,
    String? targetLabel,
    String? note,
  }) {
    final store = MockStore.instance;
    final id = 'au_${_uuid.v4()}';
    store.auditLogs[id] = AuditLog(
      id: id,
      timestamp: DateTime.now(),
      action: action,
      actorId: actor?.id,
      actorName: actor?.name,
      actorEmail: actor?.email ?? actorEmailFallback,
      actorRole: actor?.role.label,
      targetType: targetType,
      targetId: targetId,
      targetLabel: targetLabel,
      deviceLabel: describeCurrentDevice(),
      note: note,
    );
    store.notifyAuditLogs();
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final store = MockStore.instance;
    final normalized = email.trim().toLowerCase();
    final expected = store.credentials[normalized];
    if (expected == null || expected != password) {
      _audit(
        action: AuditAction.signInFailed,
        actorEmailFallback: normalized,
        note: 'Email atau kata sandi salah',
      );
      throw Exception('Email atau kata sandi salah');
    }
    final user = store.users.values.firstWhere(
      (u) => u.email.toLowerCase() == normalized,
      orElse: () => throw Exception('Pengguna tidak ditemukan'),
    );
    _currentUser = user;
    await _persist(user.id);
    _ctrl.add(user);
    _audit(action: AuditAction.signIn, actor: user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required AppUser profile,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final store = MockStore.instance;
    final normalized = email.trim().toLowerCase();
    if (store.credentials.containsKey(normalized)) {
      throw Exception('Email sudah terdaftar');
    }
    store.credentials[normalized] = password;
    store.users[profile.id] = profile;
    store.notifyUsers();
    _currentUser = profile;
    await _persist(profile.id);
    _ctrl.add(profile);
    _audit(action: AuditAction.register, actor: profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    final actor = _currentUser;
    _currentUser = null;
    await _persist(null);
    _ctrl.add(null);
    _audit(action: AuditAction.signOut, actor: actor);
  }

  @override
  Future<AppUser> updateProfile(AppUser updated) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final store = MockStore.instance;
    if (_currentUser == null || updated.id != _currentUser!.id) {
      throw Exception('Tidak ada sesi pengguna aktif');
    }
    store.users[updated.id] = updated;
    store.notifyUsers();
    _currentUser = updated;
    _ctrl.add(updated);
    _audit(action: AuditAction.profileUpdate, actor: updated);
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (_currentUser == null) {
      throw Exception('Tidak ada sesi pengguna aktif');
    }
    final store = MockStore.instance;
    final email = _currentUser!.email.toLowerCase();
    final stored = store.credentials[email];
    if (stored == null || stored != currentPassword) {
      throw Exception('Kata sandi saat ini salah');
    }
    if (newPassword.length < 6) {
      throw Exception('Kata sandi baru minimal 6 karakter');
    }
    store.credentials[email] = newPassword;
    _audit(action: AuditAction.passwordChange, actor: _currentUser);
  }
}
