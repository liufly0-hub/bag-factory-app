import '../services/api_client.dart';
import '../models/salary_setting_model.dart';
import '../models/production_record_model.dart';

class SalaryRepository {
  final ApiClient _api = ApiClient();

  Future<List<SalarySettingModel>> getSettings() async {
    final data = await _api.get('/salary-settings');
    return (data as List)
        .map((e) => SalarySettingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setSetting(SalarySettingModel setting) async {
    await _api.post('/salary-settings', body: {
      'product_type': setting.productType,
      'piece_wage': setting.pieceWage,
      'hourly_wage': setting.hourlyWage,
      'effective_date': setting.effectiveDate.toIso8601String().substring(0, 10),
    });
  }

  Future<List<ProductionRecordModel>> getApprovedRecords(
    String userId, {DateTime? start, DateTime? end,
  }) async {
    start ??= DateTime(DateTime.now().year, DateTime.now().month, 1);
    end ??= DateTime.now();
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);
    final data = await _api.get('/production-records?user_id=$userId&start=$startStr&end=$endStr');
    return (data as List)
        .map((e) => ProductionRecordModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
