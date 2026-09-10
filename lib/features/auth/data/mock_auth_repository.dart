import '../domain/app_user.dart';
import 'auth_repository.dart';

/// Implémentation simulée du dépôt d'authentification, utilisée pour le
/// prototype tant que le backend (Firebase/Node.js) n'est pas branché.
class MockAuthRepository implements AuthRepository {
  AppUser? _session;

  AppUser _demoUser({String? email, String? phone, String? fullName}) {
    return AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName ?? 'Aya Kouassi',
      email: email ?? 'aya.kouassi@transitci.ci',
      phone: phone ?? '+2250701020304',
      walletBalance: 12500,
      rating: 4.8,
      emergencyContacts: const ['+2250700000001'],
    );
  }

  @override
  Future<AppUser> login({required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    _session = _demoUser(
      email: identifier.contains('@') ? identifier : null,
      phone: identifier.contains('@') ? null : identifier,
    );
    return _session!;
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1100));
    _session = _demoUser(fullName: fullName, email: email, phone: phone).copyWith(
      walletBalance: 0,
      rating: 5.0,
    );
    return _session!;
  }

  @override
  Future<void> requestPasswordReset({required String identifier}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<AppUser> verifyOtp({required String phone, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _session = _demoUser(phone: phone);
    return _session!;
  }

  @override
  Future<AppUser> loginWithSocial(SocialProvider provider) async {
    await Future.delayed(const Duration(milliseconds: 900));
    _session = _demoUser(fullName: switch (provider) {
      SocialProvider.google => 'Utilisateur Google',
      SocialProvider.facebook => 'Utilisateur Facebook',
      SocialProvider.apple => 'Utilisateur Apple',
    });
    return _session!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _session = null;
  }

  @override
  Future<AppUser?> restoreSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _session;
  }
}
