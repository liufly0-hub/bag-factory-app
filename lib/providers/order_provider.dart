import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import '../core/constants/constants.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final orderListProvider =
    StateNotifierProvider<OrderListNotifier,
        AsyncValue<List<OrderModel>>>(
  (ref) => OrderListNotifier(ref.read(orderRepositoryProvider)),
);

class OrderListNotifier
    extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderRepository _repo;

  OrderListNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load({String? status}) async {
    try {
      final orders = await _repo.getAll(status: status);
      state = AsyncValue.data(orders);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> create(OrderModel order) async {
    await _repo.create(order);
    await load();
  }

  Future<void> update(OrderModel order) async {
    await _repo.update(order);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  /// 逾期订单
  List<OrderModel> overdueOrders(List<OrderModel> orders) {
    return orders.where((o) => o.isOverdue).toList();
  }

  /// 今日到期
  List<OrderModel> todayDeadline(List<OrderModel> orders) {
    final today = DateTime.now();
    return orders.where((o) {
      return o.deadline.year == today.year &&
          o.deadline.month == today.month &&
          o.deadline.day == today.day;
    }).toList();
  }
}
