import '../models/app_user.dart';

abstract class AuthService {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  /// Restore any persisted session from device storage. Must be awaited
  /// before runApp so the router sees the correct initial auth state.
  Future<void> init();

  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required AppUser profile,
  });
  Future<void> signOut();

  /// Update profile fields for the current user. Returns the updated user.
  Future<AppUser> updateProfile(AppUser updated);

  /// Verify current password and set a new one for the current user.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
