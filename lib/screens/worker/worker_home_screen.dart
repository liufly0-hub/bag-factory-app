import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/salary_provider.dart';
import '../../services/dashboard_aggregator.dart';
import '../../core/config/theme.dart';

class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final todayRecords = ref.watch(myDailyRecordsProvider(user?.id ?? ''));
    final wage = ref.watch(wageCalculationProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? '工人'} 您好'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日概览卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日概况',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    todayRecords.when(
                      data: (records) {
                        final stat = DashboardAggregator.workerDailyStat(
                            user?.id ?? '', records);
                        return Row(
                          children: [
                            _statItem('上报', '${stat.recordCount}次',
                                AppTheme.primary),
                            _statItem('产量', '${stat.totalQuantity}',
                                AppTheme.secondary),
                            _statItem('待审核', '${stat.pendingCount}',
                                AppTheme.warning),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) =>
                          const Text('加载失败'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 工资概览
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本月工资',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    wage.when(
                      data: (data) => Column(
                        children: [
                          Text(
                            '¥${data['monthly']?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '今日预估: ¥${data['daily']?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.secondary),
                          ),
                        ],
                      ),
                      loading: () =>
                          const CircularProgressIndicator(),
                      error: (_, __) => const Text('暂无数据'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 功能按钮区
            _menuButton(
              context,
              icon: Icons.edit_note,
              label: '生产上报',
              color: AppTheme.primary,
              onTap: () => context.push('/worker/report'),
            ),
            const SizedBox(height: 12),
            _menuButton(
              context,
              icon: Icons.account_balance_wallet,
              label: '我的工资',
              color: AppTheme.secondary,
              onTap: () => context.push('/worker/wages'),
            ),
            const SizedBox(height: 12),
            _menuButton(
              context,
              icon: Icons.calendar_month,
              label: '我的排班与工期',
              color: AppTheme.warning,
              onTap: () => context.push('/worker/schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}
