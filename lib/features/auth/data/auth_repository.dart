import '../domain/app_user.dart';

enum SocialProvider { google, facebook, apple }

/// Contrat d'authentification — l'implémentation réelle branchera Firebase
/// Auth ou une API Node.js (JWT + refresh token) derrière cette interface.
abstract class AuthRepository {
  Future<AppUser> login({required String identifier, required String password});

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> requestPasswordReset({required String identifier});

  Future<AppUser> verifyOtp({required String phone, required String code});

  Future<AppUser> loginWithSocial(SocialProvider provider);

  Future<void> logout();

  Future<AppUser?> restoreSession();
}
