import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/production_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/material_repository.dart';
import '../repositories/employee_repository.dart';
import '../services/dashboard_aggregator.dart';
import '../models/production_record_model.dart';

final productionRepoProvider =
    Provider<ProductionRepository>((ref) => ProductionRepository());
final orderRepoProvider =
    Provider<OrderRepository>((ref) => OrderRepository());
final materialRepoProvider =
    Provider<MaterialRepository>((ref) => MaterialRepository());
final employeeRepoProvider =
    Provider<EmployeeRepository>((ref) => EmployeeRepository());

/// 老板看板数据
final dashboardProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final prodRepo = ref.read(productionRepoProvider);
  final orderRepo = ref.read(orderRepoProvider);
  final matRepo = ref.read(materialRepoProvider);
  final empRepo = ref.read(employeeRepoProvider);

  final today = DateTime.now();
  final todayRecords = await prodRepo.getByDate(today);
  final activeOrders = await orderRepo.getAll(status: 'in_progress');
  final materials = await matRepo.getAll();
  final workers = await empRepo.getActiveWorkers();

  return DashboardAggregator.todaySummary(
    todayRecords,
    activeOrders,
    materials,
    workers.length,
  );
});

/// 周产量趋势
final weeklyTrendProvider =
    FutureProvider<List<DailyProduction>>((ref) async {
  final prodRepo = ref.read(productionRepoProvider);
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  final records = await prodRepo.getByDateRange(
    start: weekAgo,
    end: now,
  );

  return DashboardAggregator.weeklyTrend(records);
});
