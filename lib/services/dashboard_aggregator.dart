import '../models/production_record_model.dart';
import '../models/order_model.dart';
import '../models/material_model.dart';

/// 看板数据聚合
class DashboardAggregator {
  /// 今日全厂概况
  static DashboardSummary todaySummary(
    List<ProductionRecordModel> todayRecords,
    List<OrderModel> activeOrders,
    List<MaterialModel> materials,
    int totalWorkers,
  ) {
    int totalQuantity = 0;
    int totalDefect = 0;
    final productStats = <String, ProductStat>{};

    for (final r in todayRecords.where((r) => r.status == 'approved')) {
      totalQuantity += r.quantity;
      totalDefect += r.defectQuantity;

      productStats.update(
        r.productType,
        (existing) => ProductStat(
          quantity: existing.quantity + r.quantity,
          defect: existing.defect + r.defectQuantity,
        ),
        ifAbsent: () => ProductStat(
          quantity: r.quantity,
          defect: r.defectQuantity,
        ),
      );
    }

    final overdueOrders = activeOrders.where((o) => o.isOverdue).length;
    final lowStockMaterials =
        materials.where((m) => m.isLowStock).length;

    return DashboardSummary(
      totalQuantity: totalQuantity,
      totalDefect: totalDefect,
      defectRate: totalQuantity > 0 ? totalDefect / totalQuantity : 0,
      activeWorkers: todayRecords.map((r) => r.userId).toSet().length,
      totalWorkers: totalWorkers,
      pendingOrders: activeOrders.length,
      overdueOrders: overdueOrders,
      lowStockMaterials: lowStockMaterials,
      productStats: productStats,
    );
  }

  /// 周产量趋势
  static List<DailyProduction> weeklyTrend(
    List<ProductionRecordModel> weeklyRecords,
  ) {
    final byDate = <String, int>{};
    for (final r in weeklyRecords.where((r) => r.status == 'approved')) {
      final dateStr = r.reportDate.toIso8601String().substring(0, 10);
      byDate.update(dateStr, (v) => v + r.quantity, ifAbsent: () => r.quantity);
    }
    return byDate.entries
        .map((e) => DailyProduction(date: e.key, quantity: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 个人今日统计
  static WorkerDailyStat workerDailyStat(
    String userId,
    List<ProductionRecordModel> todayRecords,
  ) {
    final myRecords =
        todayRecords.where((r) => r.userId == userId).toList();
    int total = 0;
    int defect = 0;
    int pending = 0;
    int approved = 0;

    for (final r in myRecords) {
      total += r.quantity;
      defect += r.defectQuantity;
      if (r.status == 'pending') pending++;
      if (r.status == 'approved') approved++;
    }

    return WorkerDailyStat(
      totalQuantity: total,
      defectQuantity: defect,
      recordCount: myRecords.length,
      pendingCount: pending,
      approvedCount: approved,
    );
  }
}

class DashboardSummary {
  final int totalQuantity;
  final int totalDefect;
  final double defectRate;
  final int activeWorkers;
  final int totalWorkers;
  final int pendingOrders;
  final int overdueOrders;
  final int lowStockMaterials;
  final Map<String, ProductStat> productStats;

  DashboardSummary({
    required this.totalQuantity,
    required this.totalDefect,
    required this.defectRate,
    required this.activeWorkers,
    required this.totalWorkers,
    required this.pendingOrders,
    required this.overdueOrders,
    required this.lowStockMaterials,
    required this.productStats,
  });
}

class ProductStat {
  final int quantity;
  final int defect;

  ProductStat({required this.quantity, required this.defect});

  double get defectRate => quantity > 0 ? defect / quantity : 0;
}

class DailyProduction {
  final String date;
  final int quantity;

  DailyProduction({required this.date, required this.quantity});
}

class WorkerDailyStat {
  final int totalQuantity;
  final int defectQuantity;
  final int recordCount;
  final int pendingCount;
  final int approvedCount;

  WorkerDailyStat({
    required this.totalQuantity,
    required this.defectQuantity,
    required this.recordCount,
    required this.pendingCount,
    required this.approvedCount,
  });

  double get defectRate =>
      totalQuantity > 0 ? defectQuantity / totalQuantity : 0;
}
