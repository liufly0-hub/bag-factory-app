import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/config/theme.dart';
import '../../services/dashboard_aggregator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final weeklyTrend = ref.watch(weeklyTrendProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('数据看板')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 周产量趋势图
            const Text('周产量趋势',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: weeklyTrend.when(
                data: (trend) => _buildChart(trend),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('暂无数据')),
              ),
            ),
            const SizedBox(height: 24),

            // 今日产品分布
            const Text('今日产品分布',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            dashboard.when(
              data: (data) => _buildProductDistribution(data),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('暂无数据')),
            ),
            const SizedBox(height: 24),

            // 核心指标
            const Text('核心指标',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            dashboard.when(
              data: (data) => _buildKpiCards(data),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<DailyProduction> trend) {
    if (trend.isEmpty) {
      return const Center(child: Text('本周暂无产量数据'));
    }

    final maxQty = trend.fold<int>(
        0, (max, d) => d.quantity > max ? d.quantity : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxQty * 1.2).ceilToDouble(),
            barGroups: trend.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.quantity.toDouble(),
                    color: AppTheme.primary,
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textGray),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < trend.length) {
                      final date = trend[idx].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          date.substring(5),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textGray),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxQty * 1.2 / 4).ceilToDouble(),
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDistribution(DashboardSummary data) {
    if (data.productStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('暂无数据'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: data.productStats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(entry.key,
                        style: const TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value.quantity /
                            (data.totalQuantity > 0
                                ? data.totalQuantity
                                : 1),
                        backgroundColor: Colors.grey.shade200,
                        color: AppTheme.primary,
                        minHeight: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${entry.value.quantity}个',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKpiCards(DashboardSummary data) {
    return Column(
      children: [
        Row(
          children: [
            _kpiCard('总产量', '${data.totalQuantity}个'),
            const SizedBox(width: 8),
            _kpiCard('次品率',
                '${(data.defectRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _kpiCard('出勤工人', '${data.activeWorkers}人'),
            const SizedBox(width: 8),
            _kpiCard('逾期订单', '${data.overdueOrders}单'),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
        ),
      ),
    );
  }
}
