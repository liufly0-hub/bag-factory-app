import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/production_repository.dart';
import '../../providers/auth_provider.dart';
import '../../models/production_record_model.dart';
import '../../core/config/theme.dart';

class AuditRecordsScreen extends ConsumerStatefulWidget {
  const AuditRecordsScreen({super.key});

  @override
  ConsumerState<AuditRecordsScreen> createState() =>
      _AuditRecordsScreenState();
}

class _AuditRecordsScreenState
    extends ConsumerState<AuditRecordsScreen> {
  List<ProductionRecordModel> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final repo = ProductionRepository();
      final records = await repo.getByDate(DateTime.now());
      setState(() => _records = records);
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
        title: const Text('审核生产记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          size: 64, color: AppTheme.secondary),
                      SizedBox(height: 16),
                      Text('今天所有记录已审核完毕',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _records.length,
                    itemBuilder: (_, i) =>
                        _buildRecordCard(_records[i]),
                  ),
                ),
    );
  }

  Widget _buildRecordCard(ProductionRecordModel record) {
    final isPending = record.status == 'pending';
    final user = ref.read(authStateProvider).user;

    return Card(
      color: isPending
          ? Colors.white
          : AppTheme.statusColor(record.status).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record.productType,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.statusColor(record.status)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppTheme.statusLabel(record.status),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.statusColor(record.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _infoChip(Icons.production_quantity_limits,
                    '良品: ${record.quantity}'),
                const SizedBox(width: 12),
                _infoChip(Icons.error_outline,
                    '次品: ${record.defectQuantity}'),
              ],
            ),
            if (record.defectQuantity > 0 &&
                record.quantity > 0) ...[
              const SizedBox(height: 4),
              Text(
                '次品率: ${(record.defectQuantity / record.quantity * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      record.defectQuantity > record.quantity * 0.1
                          ? AppTheme.danger
                          : AppTheme.textGray,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _review(record.id, 'rejected', user?.id ?? ''),
                    icon: const Icon(Icons.close),
                    label: const Text('驳回'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: const BorderSide(color: AppTheme.danger),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _review(record.id, 'approved', user?.id ?? ''),
                    icon: const Icon(Icons.check),
                    label: const Text('审核通过'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textGray),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textGray)),
      ],
    );
  }

  Future<void> _review(
      String recordId, String status, String reviewerId) async {
    try {
      final repo = ProductionRepository();
      await repo.review(
        recordId: recordId,
        status: status,
        reviewerId: reviewerId,
      );
      await _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? '✓ 已审核通过' : '✗ 已驳回'),
            backgroundColor: status == 'approved'
                ? AppTheme.secondary
                : AppTheme.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}
