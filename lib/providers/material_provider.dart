import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/material_model.dart';
import '../repositories/material_repository.dart';

final materialRepositoryProvider =
    Provider<MaterialRepository>((ref) {
  return MaterialRepository();
});

final materialListProvider =
    StateNotifierProvider<MaterialListNotifier,
        AsyncValue<List<MaterialModel>>>(
  (ref) =>
      MaterialListNotifier(ref.read(materialRepositoryProvider)),
);

class MaterialListNotifier
    extends StateNotifier<AsyncValue<List<MaterialModel>>> {
  final MaterialRepository _repo;

  MaterialListNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      final materials = await _repo.getAll();
      state = AsyncValue.data(materials);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> create(MaterialModel material) async {
    await _repo.create(material);
    await load();
  }

  Future<void> addRecord(MaterialRecordModel record) async {
    await _repo.addRecord(record);
    await load();
  }

  /// 低库存列表
  List<MaterialModel> lowStock(List<MaterialModel> all) {
    return all.where((m) => m.isLowStock).toList();
  }
}
