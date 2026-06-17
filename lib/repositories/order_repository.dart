import '../services/api_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _api = ApiClient();

  Future<List<OrderModel>> getAll({String? status}) async {
    String path = '/orders';
    if (status != null) path += '?status=$status';
    final data = await _api.get(path);
    return _parseList(data);
  }

  Future<void> create(OrderModel order) async {
    await _api.post('/orders', body: {
      'customer_name': order.customerName,
      'customer_contact': order.customerContact,
      'product_type': order.productType,
      'quantity': order.quantity,
      'unit_price': order.unitPrice,
      'deadline': order.deadline.toIso8601String().substring(0, 10),
      'priority': order.priority,
      'notes': order.notes,
    });
  }

  Future<void> update(OrderModel order) async {
    await _api.put('/orders/${order.id}', body: {
      'customer_name': order.customerName,
      'product_type': order.productType,
      'quantity': order.quantity,
      'delivered_quantity': order.deliveredQuantity,
      'deadline': order.deadline.toIso8601String().substring(0, 10),
      'status': order.status,
      'priority': order.priority,
    });
  }

  Future<void> delete(String id) async {
    await _api.delete('/orders/$id');
  }

  List<OrderModel> _parseList(dynamic data) {
    if (data == null) return [];
    return (data as List)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
