import '../services/api_client.dart';
import '../models/user_model.dart';

class EmployeeRepository {
  final ApiClient _api = ApiClient();

  Future<List<UserModel>> getAll({bool? activeOnly}) async {
    final data = await _api.get('/users');
    return (data as List)
        .map((e) => UserModel.fromMap(e as Map<String, dynamic>))
        .where((u) => activeOnly != true || u.isActive)
        .toList();
  }

  Future<List<UserModel>> getActiveWorkers() async {
    final data = await _api.get('/users/workers');
    return (data as List)
        .map((e) => UserModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(UserModel user) async {
    await _api.post('/users', body: {
      'name': user.name,
      'phone': user.phone,
      'email': user.email,
      'role': user.role,
      'employee_id': user.employeeId,
    });
  }

  Future<void> toggleActive(String userId, bool active) async {
    await _api.put('/users/$userId/active', body: {'active': active});
  }

  Future<void> delete(String userId) async {
    await _api.delete('/users/$userId');
  }
}
