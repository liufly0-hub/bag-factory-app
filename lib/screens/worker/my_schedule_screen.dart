import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/production_repository.dart';
import '../../providers/auth_provider.dart';
import '../../services/deadline_estimator.dart';
import '../../core/config/theme.dart';
import '../../models/production_record_model.dart';

class MyScheduleScreen extends ConsumerWidget {
  const MyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final userId = user?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('我的排班与工期')),
      body: FutureBuilder(
        future: Future.wait([
          OrderRepository()
              .getAll(status: 'in_progress'),
          ProductionRepository().getByDateRange(
            start: DateTime.now()
                .subtract(const Duration(days: 7)),
            end: DateTime.now(),
            userId: userId,
          ),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          final orders = snapshot.data![0] as List;
          final myRecords = snapshot.data![1] as List<ProductionRecordModel>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 今天状态
              Card(
                color: AppTheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.today,
                          size: 36, color: AppTheme.primary),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateTime.now().month}月${DateTime.now().day}日 周日',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('已上报 ${myRecords.length} 条记录',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textGray)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 进行中的订单
              const Text('订单工期',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (orders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('暂无进行中的订单'),
                  ),
                )
              else
                ...orders.map((order) {
                  final days = order.deadline
                      .difference(DateTime.now())
                      .inDays;
                  final isOverdue = days < 0;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: isOverdue
                            ? AppTheme.danger
                            : AppTheme.secondary,
                        size: 32,
                      ),
                      title: Text(order.customerName,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${order.productType} × ${order.quantity}个',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        isOverdue
                            ? '逾期${-days}天'
                            : '剩余${days}天',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isOverdue
                              ? AppTheme.danger
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // 近期产量
              const Text('近7天产量',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (myRecords.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('近7天暂无记录'),
                  ),
                )
              else ...[
                // 按日期分组
                _buildRecentStats(myRecords),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentStats(List<ProductionRecordModel> records) {
    final byDate = <String, int>{};
    for (final r in records) {
      final d = r.reportDate;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      byDate.update(key, (v) => v + r.quantity,
          ifAbsent: () => r.quantity);
    }

    return Card(
      child: Column(
        children: byDate.entries.map((e) {
          return ListTile(
            leading: const Icon(Icons.calendar_today,
                size: 20, color: AppTheme.textGray),
            title: Text(e.key),
            trailing: Text('${e.value}个',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary)),
          );
        }).toList(),
      ),
    );
  }
}
