import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/salary_provider.dart';
import '../../providers/production_provider.dart';
import '../../services/dashboard_aggregator.dart';
import '../../services/wage_calculator.dart';
import '../../models/production_record_model.dart';
import '../../models/salary_setting_model.dart';
import '../../core/config/theme.dart';

class MyWagesScreen extends ConsumerWidget {
  const MyWagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final todayRecords = ref.watch(myDailyRecordsProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(title: const Text('我的工资')),
      body: todayRecords.when(
        data: (records) => _buildWageView(context, ref, user?.id ?? '', records),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildWageView(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<ProductionRecordModel> todayRecords,
  ) {
    final stat = DashboardAggregator.workerDailyStat(userId, todayRecords);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 今日统计卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('今日统计',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoItem('上报次数', '${stat.recordCount}'),
                    _infoItem('良品', '${stat.totalQuantity}'),
                    _infoItem('次品', '${stat.defectQuantity}'),
                    _infoItem('次品率',
                        '${(stat.defectRate * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 近期工资趋势（简版）
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('本月记录',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (todayRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('今天还没有上报记录',
                        style: TextStyle(color: AppTheme.textGray)),
                  )
                else
                  ...todayRecords.take(10).map((r) => ListTile(
                        title: Text(r.productType,
                            style: const TextStyle(fontSize: 16)),
                        subtitle: Text(
                            '${r.quantity}个 | 次品${r.defectQuantity}个'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.statusColor(r.status)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppTheme.statusLabel(r.status),
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  AppTheme.statusColor(r.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textGray)),
      ],
    );
  }
}
