import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // 登录成功后跳转
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isLoggedIn) {
        if (next.isBoss) {
          context.go('/boss');
        } else {
          context.go('/');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.factory_outlined, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('宏信工厂助手', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('义乌市宏信箱包厂 · 内部管理系统', style: TextStyle(fontSize: 14, color: AppTheme.textGray)),
              const SizedBox(height: 48),

              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '输入管理员邮箱',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  hintText: '输入密码',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : () {
                    ref.read(authStateProvider.notifier).loginWithEmail(
                      _emailCtrl.text.trim(),
                      _pwdCtrl.text,
                    );
                  },
                  child: Text(authState.isLoading ? '登录中...' : '登录'),
                ),
              ),

              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(authState.error!, style: TextStyle(color: AppTheme.danger, fontSize: 14)),
              ],

              const SizedBox(height: 40),
              Text('登录账号: 3389716868@qq.com / boss8888', style: TextStyle(fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
        ),
      ),
    );
  }
}
