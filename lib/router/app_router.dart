import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/worker/worker_home_screen.dart';
import '../screens/worker/production_report_screen.dart';
import '../screens/worker/my_wages_screen.dart';
import '../screens/worker/my_schedule_screen.dart';
import '../screens/boss/boss_home_screen.dart';
import '../screens/boss/dashboard_screen.dart';
import '../screens/boss/audit_records_screen.dart';
import '../screens/boss/order_management_screen.dart';
import '../screens/boss/material_management_screen.dart';
import '../screens/boss/employee_management_screen.dart';
import '../screens/boss/salary_settings_screen.dart';
import '../screens/boss/wage_report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = authState.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';

      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      // 工人端路由
      GoRoute(
        path: '/',
        builder: (_, __) => const WorkerHomeScreen(),
      ),
      GoRoute(
        path: '/worker/report',
        builder: (_, __) => const ProductionReportScreen(),
      ),
      GoRoute(
        path: '/worker/wages',
        builder: (_, __) => const MyWagesScreen(),
      ),
      GoRoute(
        path: '/worker/schedule',
        builder: (_, __) => const MyScheduleScreen(),
      ),
      // 老板端路由
      GoRoute(
        path: '/boss',
        builder: (_, __) => const BossHomeScreen(),
      ),
      GoRoute(
        path: '/boss/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/boss/audit',
        builder: (_, __) => const AuditRecordsScreen(),
      ),
      GoRoute(
        path: '/boss/orders',
        builder: (_, __) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/boss/materials',
        builder: (_, __) => const MaterialManagementScreen(),
      ),
      GoRoute(
        path: '/boss/employees',
        builder: (_, __) => const EmployeeManagementScreen(),
      ),
      GoRoute(
        path: '/boss/salary-settings',
        builder: (_, __) => const SalarySettingsScreen(),
      ),
      GoRoute(
        path: '/boss/wage-report',
        builder: (_, __) => const WageReportScreen(),
      ),
    ],
  );
});
