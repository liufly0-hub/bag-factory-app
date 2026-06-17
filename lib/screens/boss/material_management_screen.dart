import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/material_provider.dart';
import '../../models/material_model.dart';
import '../../core/constants/constants.dart';
import '../../core/config/theme.dart';

class MaterialManagementScreen extends ConsumerStatefulWidget {
  const MaterialManagementScreen({super.key});

  @override
  ConsumerState<MaterialManagementScreen> createState() =>
      _MaterialManagementScreenState();
}

class _MaterialManagementScreenState
    extends ConsumerState<MaterialManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(materialListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('物料管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMaterialDialog(),
          ),
        ],
      ),
      body: materialsAsync.when(
        data: (materials) {
          final lowStock =
              ref.read(materialListProvider.notifier).lowStock(materials);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (lowStock.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning,
                          color: AppTheme.danger),
                      const SizedBox(width: 8),
                      Text(
                        '${lowStock.length}项物料库存不足',
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ...materials.map((m) => _buildMaterialCard(m)),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material) {
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
                  child: Text(material.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(material.category,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '库存: ${material.currentStock}${material.unit}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: material.isLowStock
                        ? AppTheme.danger
                        : AppTheme.primary,
                  ),
                ),
                if (material.minStockAlarm > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(预警: ${material.minStockAlarm}${material.unit})',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textGray),
                  ),
                ],
              ],
            ),
            if (material.supplier != null) ...[
              const SizedBox(height: 4),
              Text('供应商: ${material.supplier}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGray)),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _showRecordDialog(material),
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('出入库'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMaterialDialog() {
    final nameCtrl = TextEditingController();
    String category = MaterialCategory.raw;
    final unitCtrl = TextEditingController(text: '公斤');
    final stockCtrl = TextEditingController();
    final alarmCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final supplierCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加物料'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: '物料名称')),
              DropdownButtonFormField(
                value: category,
                items: MaterialCategory.all
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => category = v!,
                decoration:
                    const InputDecoration(labelText: '类别'),
              ),
              TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(
                      labelText: '单位（公斤/卷/个）')),
              TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: '初始库存')),
              TextField(
                  controller: alarmCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: '最低库存预警')),
              TextField(
                  controller: costCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: '单价')),
              TextField(
                  controller: supplierCtrl,
                  decoration: const InputDecoration(
                      labelText: '供应商')),
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
              await ref
                  .read(materialListProvider.notifier)
                  .create(MaterialModel(
                    id: '',
                    name: nameCtrl.text,
                    category: category,
                    unit: unitCtrl.text,
                    currentStock:
                        double.tryParse(stockCtrl.text) ?? 0,
                    minStockAlarm:
                        double.tryParse(alarmCtrl.text) ?? 0,
                    costPerUnit:
                        double.tryParse(costCtrl.text),
                    supplier: supplierCtrl.text,
                  ));
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showRecordDialog(MaterialModel material) {
    final qtyCtrl = TextEditingController();
    String type = 'in';
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${material.name} - 出入库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton(
              segments: const [
                ButtonSegment(value: 'in', label: Text('入库')),
                ButtonSegment(value: 'out', label: Text('出库')),
              ],
              selected: {type},
              onSelectionChanged: (v) => type = v.first,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '数量 (${material.unit})',
              ),
            ),
            TextField(
              controller: noteCtrl,
              decoration:
                  const InputDecoration(labelText: '备注（可选）'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final qty =
                  double.tryParse(qtyCtrl.text) ?? 0;
              if (qty <= 0) return;
              await ref
                  .read(materialListProvider.notifier)
                  .addRecord(MaterialRecordModel(
                    id: '',
                    materialId: material.id,
                    materialName: material.name,
                    type: type,
                    quantity: qty,
                    notes: noteCtrl.text,
                  ));
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
