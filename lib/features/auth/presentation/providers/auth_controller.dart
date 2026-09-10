import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../data/mock_auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

/// Contrôleur d'authentification exposant les actions (login, register,
/// OTP, connexion sociale) et l'état courant de session.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthInitial();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _restore() async {
    final user = await _repository.restoreSession();
    state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
  }

  Future<bool> login({required String identifier, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(identifier: identifier, password: password);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> requestPasswordReset(String identifier) async {
    try {
      await _repository.requestPasswordReset(identifier: identifier);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String code}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.verifyOtp(phone: phone, code: code);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> loginWithSocial(SocialProvider provider) async {
    state = const AuthLoading();
    try {
      final user = await _repository.loginWithSocial(provider);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  void updateUser(AppUser user) {
    state = AuthAuthenticated(user);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(authControllerProvider);
  return state is AuthAuthenticated ? state.user : null;
});
