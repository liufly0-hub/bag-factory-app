import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme.dart';
import 'router/app_router.dart';

class BagFactoryApp extends ConsumerWidget {
  const BagFactoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '宏信工厂助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.workerTheme(),
      routerConfig: router,
    );
  }
}
