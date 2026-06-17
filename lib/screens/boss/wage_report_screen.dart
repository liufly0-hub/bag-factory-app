import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/salary_repository.dart';
import '../../repositories/employee_repository.dart';
import '../../repositories/production_repository.dart';
import '../../services/wage_calculator.dart';
import '../../services/dashboard_aggregator.dart';
import '../../core/config/theme.dart';

class WageReportScreen extends ConsumerStatefulWidget {
  const WageReportScreen({super.key});

  @override
  ConsumerState<WageReportScreen> createState() =>
      _WageReportScreenState();
}

class _WageReportScreenState
    extends ConsumerState<WageReportScreen> {
  List<_WorkerWage> _workerWages = [];
  bool _isLoading = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final salaryRepo = SalaryRepository();
      final empRepo = EmployeeRepository();
      final prodRepo = ProductionRepository();

      final settings = await salaryRepo.getSettings();
      final settingMap = <String, dynamic>{};
      for (final s in settings) {
        settingMap[s.productType] = s;
      }

      final workers = await empRepo.getActiveWorkers();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final wages = <_WorkerWage>[];
      for (final worker in workers) {
        final records = await prodRepo.getByDateRange(
          start: monthStart,
          end: now,
          userId: worker.id,
        );
        final approvedRecords =
            records.where((r) => r.status == 'approved').toList();

        // 按产品汇总
        final productSummary = <String, int>{};
        int totalDefect = 0;
        for (final r in approvedRecords) {
          productSummary.update(
            r.productType,
            (v) => v + r.quantity,
            ifAbsent: () => r.quantity,
          );
          totalDefect += r.defectQuantity;
        }

        final totalQty =
            approvedRecords.fold<int>(0, (s, r) => s + r.quantity);
        final wage = WageCalculator.calculateMonthlyWage(
            approvedRecords,
            settingMap
                .map((k, v) => MapEntry(k, v as dynamic)));

        wages.add(_WorkerWage(
          name: worker.name,
          totalQuantity: totalQty,
          totalDefect: totalDefect,
          monthlyWage: wage,
          recordCount: approvedRecords.length,
          productSummary: productSummary,
        ));
      }

      wages.sort((a, b) => b.monthlyWage.compareTo(a.monthlyWage));
      setState(() => _workerWages = wages);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('薪酬报表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workerWages.isEmpty
              ? const Center(child: Text('本月暂无数据'))
              : Column(
                  children: [
                    // 统计总览
                    _buildTotalBar(),
                    const Divider(height: 1),
                    // 工人列表
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _workerWages.length,
                        itemBuilder: (_, i) =>
                            _buildWageCard(_workerWages[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTotalBar() {
    final totalWage =
        _workerWages.fold<double>(0, (s, w) => s + w.monthlyWage);
    final totalQty =
        _workerWages.fold<int>(0, (s, w) => s + w.totalQuantity);

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primary.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('${_workerWages.length}人',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const Text('在职工人',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
          Column(
            children: [
              Text('${totalQty}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary)),
              const Text('本月总产量',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
          Column(
            children: [
              Text('¥${totalWage.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.danger)),
              const Text('本月总工资',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWageCard(_WorkerWage wage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(wage.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                  '¥${wage.monthlyWage.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '产量: ${wage.totalQuantity}个',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textGray),
                ),
                const SizedBox(width: 16),
                Text(
                  '记录: ${wage.recordCount}条',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textGray),
                ),
              ],
            ),
            if (wage.productSummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: wage.productSummary.entries
                    .map((e) => Chip(
                          label: Text(
                            '${e.key} ${e.value}个',
                            style: const TextStyle(
                                fontSize: 12),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkerWage {
  final String name;
  final int totalQuantity;
  final int totalDefect;
  final double monthlyWage;
  final int recordCount;
  final Map<String, int> productSummary;

  _WorkerWage({
    required this.name,
    required this.totalQuantity,
    required this.totalDefect,
    required this.monthlyWage,
    required this.recordCount,
    required this.productSummary,
  });
}
