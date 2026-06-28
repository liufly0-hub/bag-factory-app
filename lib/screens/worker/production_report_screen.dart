import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import '../../core/constants/constants.dart';
import '../../core/config/theme.dart';
import '../../core/utils/image_utils.dart';
import '../../models/production_record_model.dart';
import '../../repositories/production_repository.dart';
import '../../providers/auth_provider.dart';

class ProductionReportScreen extends ConsumerStatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  ConsumerState<ProductionReportScreen> createState() =>
      _ProductionReportScreenState();
}

class _ProductionReportScreenState
    extends ConsumerState<ProductionReportScreen> {
  String _selectedProduct = ProductTypes.all.first;
  final _qtyCtrl = TextEditingController();
  final _defectCtrl = TextEditingController();
  XFile? _photoFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _defectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生产上报')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选择产品 - 大卡片选择
            const Text('选择产品',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildProductSelector(),
            const SizedBox(height: 24),

            // 生产数量
            const Text('生产数量（良品）',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '输入数量',
                suffixText: '个',
                suffixStyle: const TextStyle(fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 24),
              ),
            ),
            const SizedBox(height: 24),

            // 次品数量
            const Text('次品数量（可选）',
                style: TextStyle(
                    fontSize: 16, color: AppTheme.textGray)),
            const SizedBox(height: 8),
            TextField(
              controller: _defectCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '个',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // 拍照
            const Text('拍照留证（可选）',
                style: TextStyle(
                    fontSize: 16, color: AppTheme.textGray)),
            const SizedBox(height: 12),
            Center(
              child: _buildPhotoWidget(),
            ),
            const SizedBox(height: 32),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                          color: Colors.white)
                    : const Text('确认上报',
                          style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ProductTypes.all.map((product) {
        final selected = product == _selectedProduct;
        return GestureDetector(
          onTap: () => setState(() => _selectedProduct = product),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primary
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppTheme.primary
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              product,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoWidget() {
    return PhotoCaptureWidget(
      imageFile: _photoFile,
      onImageChanged: (f) => setState(() => _photoFile = f),
      size: 200,
    );
  }

  Future<void> _pickPhoto() async {
    final file = await ImageUtils.takePhoto();
    if (file != null) setState(() => _photoFile = file);
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的生产数量')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).user;
      if (user == null) return;

      final record = ProductionRecordModel(
        id: '',
        userId: user.id,
        productType: _selectedProduct,
        quantity: qty,
        defectQuantity:
            int.tryParse(_defectCtrl.text.trim()) ?? 0,
        photoUrl: _photoFile?.path ?? '',
        reportDate: DateTime.now(),
        status: 'pending',
      );

      final repo = ProductionRepository();
      await repo.submit(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ 上报成功，等待老板审核'),
            backgroundColor: AppTheme.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上报失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
