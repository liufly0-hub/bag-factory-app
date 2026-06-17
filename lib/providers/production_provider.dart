import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/production_record_model.dart';
import '../repositories/production_repository.dart';

final productionRepositoryProvider =
    Provider<ProductionRepository>((ref) {
  return ProductionRepository();
});

/// 某天的生产记录
final dailyRecordsProvider =
    StateNotifierProvider.family<DailyRecordsNotifier,
        AsyncValue<List<ProductionRecordModel>>, DateTime>(
  (ref, date) => DailyRecordsNotifier(
    ref.read(productionRepositoryProvider),
    date,
  ),
);

class DailyRecordsNotifier
    extends StateNotifier<AsyncValue<List<ProductionRecordModel>>> {
  final ProductionRepository _repo;
  final DateTime date;

  DailyRecordsNotifier(this._repo, this.date)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final records = await _repo.getByDate(date);
      state = AsyncValue.data(records);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() => load();
}

/// 个人某天的生产记录
final myDailyRecordsProvider =
    FutureProvider.family<List<ProductionRecordModel>, String>(
  (ref, userId) async {
    final repo = ref.read(productionRepositoryProvider);
    return repo.getByUserAndDate(
      userId: userId,
      date: DateTime.now(),
    );
  },
);
