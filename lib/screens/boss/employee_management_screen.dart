import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/employee_repository.dart';
import '../../models/user_model.dart';
import '../../core/config/theme.dart';

class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState
    extends ConsumerState<EmployeeManagementScreen> {
  List<UserModel> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final repo = EmployeeRepository();
      final employees = await repo.getAll();
      setState(() => _employees = employees);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('员工管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
              ? const Center(child: Text('暂无员工'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _employees.length,
                    itemBuilder: (_, i) =>
                        _buildEmployeeCard(_employees[i]),
                  ),
                ),
    );
  }

  Widget _buildEmployeeCard(UserModel employee) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: employee.isBoss
              ? AppTheme.warning
              : AppTheme.primary,
          child: Text(
            employee.name.isNotEmpty
                ? employee.name[0]
                : '?',
            style: const TextStyle(
                fontSize: 22, color: Colors.white),
          ),
        ),
        title: Text(employee.name,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.isBoss ? '管理员' : '工人',
              style: TextStyle(
                  fontSize: 13,
                  color: employee.isBoss
                      ? AppTheme.warning
                      : AppTheme.primary),
            ),
            if (employee.employeeId != null)
              Text('工号: ${employee.employeeId}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textGray)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (employee.isWorker)
              Switch(
                value: employee.isActive,
                onChanged: (v) =>
                    _toggleActive(employee.id, v),
                activeColor: AppTheme.secondary,
              ),
            if (employee.isWorker)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.danger),
                onPressed: () =>
                    _showDeleteConfirm(employee),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加员工'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: '姓名')),
            TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: '手机号')),
            TextField(
                controller: idCtrl,
                decoration:
                    const InputDecoration(labelText: '工号')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = EmployeeRepository();
                await repo.create(UserModel(
                  id: '',
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  role: 'worker',
                  employeeId: idCtrl.text,
                ));
                await _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('添加失败: $e')),
                  );
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(
      String userId, bool active) async {
    try {
      final repo = EmployeeRepository();
      await repo.toggleActive(userId, active);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _showDeleteConfirm(UserModel employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除员工 ${employee.name} 吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = EmployeeRepository();
                await repo.delete(employee.id);
                await _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
