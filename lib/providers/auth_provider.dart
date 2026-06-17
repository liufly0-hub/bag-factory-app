import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref.read(authRepositoryProvider)),
);

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({this.isLoading = false, this.user, this.error});

  bool get isLoggedIn => user != null;
  bool get isBoss => user?.isBoss ?? false;
  bool get isWorker => user?.isWorker ?? false;

  AuthState copyWith({bool? isLoading, UserModel? user, String? error, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthStateNotifier(this._repo) : super(const AuthState()) {
    // 检查是否已有token
    if (_repo.isLoggedIn) {
      state = const AuthState();
    }
  }

  /// 邮箱密码登录
  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repo.login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '邮箱或密码错误');
      return false;
    }
  }

  /// 退出
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}
