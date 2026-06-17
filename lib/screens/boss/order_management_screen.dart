import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/config/theme.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState
    extends ConsumerState<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showOrderDialog(),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('暂无订单'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) => _buildOrderCard(orders[i]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(order.customerName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.statusColor(order.status)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppTheme.statusLabel(order.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.statusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.productType} × ${order.quantity}个',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: AppTheme.secondary),
                const SizedBox(width: 4),
                Text(
                  '已交付: ${order.deliveredQuantity}个',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGray),
                ),
                const Spacer(),
                Icon(
                  order.isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.schedule,
                  size: 16,
                  color: order.isOverdue
                      ? AppTheme.danger
                      : AppTheme.textGray,
                ),
                const SizedBox(width: 4),
                Text(
                  date_utils.AppDateUtils.remainingDays(order.deadline),
                  style: TextStyle(
                    fontSize: 13,
                    color: order.isOverdue
                        ? AppTheme.danger
                        : AppTheme.textGray,
                    fontWeight:
                        order.isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order.progress,
                backgroundColor: Colors.grey.shade200,
                color: order.isOverdue
                    ? AppTheme.danger
                    : AppTheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showDeliveryDialog(order),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('更新交付'),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showDeleteConfirm(order.id),
                  icon: const Icon(Icons.delete_outline,
                      size: 18),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.danger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog({OrderModel? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?.customerName ?? '');
    final contactCtrl =
        TextEditingController(text: existing?.customerContact ?? '');
    String productType = existing?.productType ?? ProductTypes.all.first;
    final qtyCtrl = TextEditingController(
        text: existing?.quantity.toString() ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.unitPrice?.toString() ?? '');
    DateTime deadline = existing?.deadline ?? DateTime.now().add(const Duration(days: 30));
    String priority = existing?.priority ?? 'normal';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? '编辑订单' : '新建订单'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: '客户名称')),
                TextField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                        labelText: '联系方式')),
                DropdownButtonFormField(
                  value: productType,
                  items: ProductTypes.all
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => productType = v!),
                  decoration: const InputDecoration(labelText: '产品类型'),
                ),
                TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: '数量')),
                TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: '单价')),
                ListTile(
                  title: Text('交期: ${date_utils.AppDateUtils.formatDate(deadline)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => deadline = picked);
                    }
                  },
                ),
                DropdownButtonFormField(
                  value: priority,
                  items: Priority.all
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(AppTheme.statusLabel(p))))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => priority = v!),
                  decoration:
                      const InputDecoration(labelText: '优先级'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final order = OrderModel(
                  id: existing?.id ?? '',
                  customerName: nameCtrl.text,
                  customerContact: contactCtrl.text,
                  productType: productType,
                  quantity: int.tryParse(qtyCtrl.text) ?? 0,
                  unitPrice: double.tryParse(priceCtrl.text),
                  deadline: deadline,
                  priority: priority,
                  status: existing?.status ?? 'pending',
                );
                if (existing != null) {
                  await ref
                      .read(orderListProvider.notifier)
                      .update(order);
                } else {
                  await ref
                      .read(orderListProvider.notifier)
                      .create(order);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDialog(OrderModel order) {
    final ctrl = TextEditingController(
        text: order.deliveredQuantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更新交付数量'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '已交付数量 (共${order.quantity}个)',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final qty = int.tryParse(ctrl.text) ?? 0;
              if (qty > order.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('交付数量不能超过订单总量')),
                );
                return;
              }
              await ref.read(orderListProvider.notifier).update(
                    OrderModel(
                      id: order.id,
                      customerName: order.customerName,
                      productType: order.productType,
                      quantity: order.quantity,
                      deliveredQuantity: qty,
                      deadline: order.deadline,
                      status: qty >= order.quantity
                          ? 'completed'
                          : order.status,
                    ),
                  );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个订单吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(orderListProvider.notifier)
                  .delete(id);
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
