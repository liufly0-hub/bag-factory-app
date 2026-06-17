import '../services/api_client.dart';
import '../models/production_record_model.dart';

class ProductionRepository {
  final ApiClient _api = ApiClient();

  Future<void> submit(ProductionRecordModel record) async {
    await _api.post('/production-records', body: {
      'product_type': record.productType,
      'quantity': record.quantity,
      'defect_quantity': record.defectQuantity,
      'photo_url': record.photoUrl,
      'report_date': record.reportDate.toIso8601String().substring(0, 10),
      'remark': record.remark,
    });
  }

  Future<List<ProductionRecordModel>> getByUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final data = await _api.get('/production-records?user_id=$userId&date=$dateStr');
    return _parseList(data);
  }

  Future<List<ProductionRecordModel>> getByDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final data = await _api.get('/production-records?date=$dateStr');
    return _parseList(data);
  }

  Future<List<ProductionRecordModel>> getByDateRange({
    required DateTime start, required DateTime end, String? userId,
  }) async {
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);
    String path = '/production-records?start=$startStr&end=$endStr';
    if (userId != null) path += '&user_id=$userId';
    final data = await _api.get(path);
    return _parseList(data);
  }

  Future<void> review({
    required String recordId, required String status,
    required String reviewerId, String? remark,
  }) async {
    await _api.put('/production-records/$recordId/review', body: {
      'status': status,
      if (remark != null) 'remark': remark,
    });
  }

  List<ProductionRecordModel> _parseList(dynamic data) {
    if (data == null) return [];
    return (data as List)
        .map((e) => ProductionRecordModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
