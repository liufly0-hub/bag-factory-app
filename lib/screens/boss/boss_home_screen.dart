import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/theme.dart';
import '../../services/dashboard_aggregator.dart';

class BossHomeScreen extends ConsumerWidget {
  const BossHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final dashboard = ref.watch(dashboardProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('老板端 · ${user?.name ?? ''}'),
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
        padding: const EdgeInsets.all(16),
        child: dashboard.when(
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 今日快报
              _buildSummaryCards(data),
              const SizedBox(height: 20),

              // 功能菜单
              const Text('管理功能',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildMenuGrid(context),
            ],
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text('加载失败: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummary data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('今日概览',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _summaryCard('今日产量', '${data.totalQuantity}个',
                AppTheme.primary, Icons.factory),
            const SizedBox(width: 8),
            _summaryCard('在职工人', '${data.activeWorkers}人',
                AppTheme.secondary, Icons.people),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _summaryCard('进行中订单', '${data.pendingOrders}单',
                AppTheme.warning, Icons.receipt_long),
            const SizedBox(width: 8),
            _summaryCard('低库存预警', '${data.lowStockMaterials}项',
                AppTheme.danger, Icons.inventory),
          ],
        ),
        if (data.overdueOrders > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning,
                    color: AppTheme.danger, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${data.overdueOrders}个订单已逾期，请及时处理',
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _summaryCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      _MenuItem('数据看板', Icons.dashboard, AppTheme.primary,
          '/boss/dashboard'),
      _MenuItem('审核记录', Icons.rate_review, AppTheme.warning,
          '/boss/audit'),
      _MenuItem('订单管理', Icons.receipt, AppTheme.secondary,
          '/boss/orders'),
      _MenuItem('物料管理', Icons.inventory, Colors.orange,
          '/boss/materials'),
      _MenuItem('员工管理', Icons.people, Colors.purple,
          '/boss/employees'),
      _MenuItem('工价设置', Icons.attach_money, AppTheme.danger,
          '/boss/salary-settings'),
      _MenuItem('薪酬报表', Icons.bar_chart, Colors.teal,
          '/boss/wage-report'),
    ];

    return Column(
      children: [
        for (var i = 0; i < menus.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                    child: _menuCard(
                        context, menus[i])),
                if (i + 1 < menus.length)
                  const SizedBox(width: 12),
                if (i + 1 < menus.length)
                  Expanded(
                      child: _menuCard(
                          context, menus[i + 1])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _menuCard(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(item.icon,
                  size: 40, color: item.color),
              const SizedBox(height: 8),
              Text(item.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  _MenuItem(this.label, this.icon, this.color, this.route);
}
