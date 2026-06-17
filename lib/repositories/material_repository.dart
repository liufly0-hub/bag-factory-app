import '../services/api_client.dart';
import '../models/material_model.dart';

class MaterialRepository {
  final ApiClient _api = ApiClient();

  Future<List<MaterialModel>> getAll() async {
    final data = await _api.get('/materials');
    return (data as List)
        .map((e) => MaterialModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(MaterialModel material) async {
    await _api.post('/materials', body: {
      'name': material.name,
      'category': material.category,
      'unit': material.unit,
      'current_stock': material.currentStock,
      'min_stock_alarm': material.minStockAlarm,
      'cost_per_unit': material.costPerUnit,
      'supplier': material.supplier,
    });
  }

  Future<void> addRecord(MaterialRecordModel record) async {
    await _api.post('/material-records', body: {
      'material_id': record.materialId,
      'type': record.type,
      'quantity': record.quantity,
      'notes': record.notes,
    });
  }
}
