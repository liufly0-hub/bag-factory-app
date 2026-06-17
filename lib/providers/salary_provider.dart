import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/salary_setting_model.dart';
import '../models/production_record_model.dart';
import '../repositories/salary_repository.dart';
import '../services/wage_calculator.dart';

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  return SalaryRepository();
});

/// 工价标准列表
final salarySettingsProvider =
    StateNotifierProvider<SalarySettingsNotifier,
        AsyncValue<List<SalarySettingModel>>>(
  (ref) =>
      SalarySettingsNotifier(ref.read(salaryRepositoryProvider)),
);

class SalarySettingsNotifier
    extends StateNotifier<AsyncValue<List<SalarySettingModel>>> {
  final SalaryRepository _repo;

  SalarySettingsNotifier(this._repo)
      : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      final settings = await _repo.getSettings();
      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setSetting(SalarySettingModel setting) async {
    await _repo.setSetting(setting);
    await load();
  }

  /// 获取产品当前工价
  Future<SalarySettingModel?> getCurrent(String productType) async {
    final settings = await _repo.getSettings();
    return settings.cast<SalarySettingModel?>().firstWhere(
      (s) => s?.productType == productType,
      orElse: () => null,
    );
  }
}

/// 工人工资计算
final wageCalculationProvider =
    FutureProvider.family<Map<String, double>, String>(
  (ref, userId) async {
    final repo = ref.read(salaryRepositoryProvider);
    final settings = await repo.getSettings();
    final records = await repo.getApprovedRecords(userId);

    final settingMap = <String, SalarySettingModel>{};
    for (final s in settings) {
      settingMap[s.productType] = s;
    }

    final monthlyWage =
        WageCalculator.calculateMonthlyWage(records, settingMap);
    final dailyWage = WageCalculator.calculateDailyWage(
      records.where((r) {
        final now = DateTime.now();
        return r.reportDate.year == now.year &&
            r.reportDate.month == now.month &&
            r.reportDate.day == now.day;
      }).toList(),
      settingMap,
    );

    return {
      'daily': dailyWage,
      'monthly': monthlyWage,
      'pending': records
          .where((r) => r.status == 'pending')
          .length
          .toDouble(),
    };
  },
);
