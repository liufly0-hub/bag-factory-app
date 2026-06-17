import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 工厂APP API客户端
class ApiClient {
  // 后端API地址 - 香港服务器
  static const String baseUrl = 'http://47.242.208.77:3100/api';

  static String? _token;
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  /// 初始化 - 从本地恢复token
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
  }

  /// 设置token并持久化
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  /// 清除token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  bool get isLoggedIn => _token != null;

  /// 通用请求头
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET
  Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final res = await http.get(url, headers: _headers);
    if (res.statusCode == 401) throw AuthException('未登录');
    if (res.statusCode >= 400) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  /// POST
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$path');
    final res = await http.post(url, headers: _headers, body: body != null ? jsonEncode(body) : null);
    if (res.statusCode == 401) throw AuthException('未登录');
    if (res.statusCode >= 400) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  /// PUT
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$path');
    final res = await http.put(url, headers: _headers, body: body != null ? jsonEncode(body) : null);
    if (res.statusCode == 401) throw AuthException('未登录');
    if (res.statusCode >= 400) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  /// DELETE
  Future<dynamic> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final res = await http.delete(url, headers: _headers);
    if (res.statusCode == 401) throw AuthException('未登录');
    if (res.statusCode >= 400) throw ApiException(res.body);
    return jsonDecode(res.body);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'API错误: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
