import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salary_provider.dart';
import '../../repositories/salary_repository.dart';
import '../../models/salary_setting_model.dart';
import '../../core/constants/constants.dart';
import '../../core/config/theme.dart';

class SalarySettingsScreen extends ConsumerStatefulWidget {
  const SalarySettingsScreen({super.key});

  @override
  ConsumerState<SalarySettingsScreen> createState() =>
      _SalarySettingsScreenState();
}

class _SalarySettingsScreenState
    extends ConsumerState<SalarySettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(salarySettingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(salarySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('工价标准设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money,
                      size: 64, color: AppTheme.textGray),
                  SizedBox(height: 16),
                  Text('暂无工价设置',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('点击右上角 + 添加',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray)),
                ],
              ),
            );
          }
          // 按产品分组，只显示最新工价
          final latest = <String, SalarySettingModel>{};
          for (final s in settings) {
            if (!latest.containsKey(s.productType) ||
                s.effectiveDate
                    .isAfter(latest[s.productType]!.effectiveDate)) {
              latest[s.productType] = s;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: AppTheme.primary.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.primary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '计件工资 = 良品数量 × 单价',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...latest.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '¥${entry.value.pieceWage}/个 | 时薪¥${entry.value.hourlyWage}/h',
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray),
                    ),
                    trailing: Text(
                      '生效: ${entry.value.effectiveDate.toIso8601String().substring(0, 10)}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGray),
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('加载失败: $err')),
      ),
    );
  }

  void _showAddDialog() {
    String productType = ProductTypes.all.first;
    final pieceWageCtrl = TextEditingController();
    final hourlyWageCtrl = TextEditingController();
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('添加工价标准'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: productType,
                items: ProductTypes.all
                    .map((p) => DropdownMenuItem(
                        value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => productType = v!),
                decoration:
                    const InputDecoration(labelText: '产品类型'),
              ),
              TextField(
                controller: pieceWageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '计件单价（元/个）'),
              ),
              TextField(
                controller: hourlyWageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '时薪（元/小时，可选）'),
              ),
              ListTile(
                title: Text(
                    '生效日期: ${date.toIso8601String().substring(0, 10)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 30)),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => date = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final pieceWage =
                    double.tryParse(pieceWageCtrl.text) ?? 0;
                if (pieceWage <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('单价必须大于0')),
                  );
                  return;
                }
                await ref
                    .read(salarySettingsProvider.notifier)
                    .setSetting(SalarySettingModel(
                      id: '',
                      productType: productType,
                      pieceWage: pieceWage,
                      hourlyWage:
                          double.tryParse(hourlyWageCtrl.text) ?? 0,
                      effectiveDate: date,
                    ));
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
