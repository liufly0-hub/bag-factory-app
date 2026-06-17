import '../services/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _api = ApiClient();

  bool get isLoggedIn => _api.isLoggedIn;

  /// 邮箱密码登录
  Future<UserModel> login(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await ApiClient.setToken(data['token'] as String);
    return UserModel.fromMap(data['user'] as Map<String, dynamic>);
  }

  /// 获取当前用户资料（从token解码）
  Future<UserModel?> getProfile() async {
    try {
      final data = await _api.get('/users');
      return null; // 登录后会有token，profile在登录时已返回
    } catch (_) {
      return null;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await ApiClient.clearToken();
  }
}
