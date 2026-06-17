import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化API客户端（恢复登录token）
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('api_token');
  if (token != null) {
    // 恢复token（await next tick消黄牌）
    await Future.microtask(() => ApiClient.setToken(token));
  }

  runApp(const BagFactoryApp());
}
