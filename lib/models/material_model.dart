class MaterialModel {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;
  final double minStockAlarm;
  final double? costPerUnit;
  final String? supplier;
  final DateTime? createdAt;

  MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.currentStock = 0,
    this.minStockAlarm = 0,
    this.costPerUnit,
    this.supplier,
    this.createdAt,
  });

  bool get isLowStock => currentStock <= minStockAlarm && minStockAlarm > 0;

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      unit: map['unit'] as String,
      currentStock: (map['current_stock'] as num?)?.toDouble() ?? 0,
      minStockAlarm: (map['min_stock_alarm'] as num?)?.toDouble() ?? 0,
      costPerUnit: (map['cost_per_unit'] as num?)?.toDouble(),
      supplier: map['supplier'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'unit': unit,
    'current_stock': currentStock,
    'min_stock_alarm': minStockAlarm,
    'cost_per_unit': costPerUnit,
    'supplier': supplier,
  };
}

class MaterialRecordModel {
  final String id;
  final String materialId;
  final String materialName;
  final String type;
  final double quantity;
  final String? operatorId;
  final String? relatedOrderId;
  final String? notes;
  final DateTime? createdAt;

  MaterialRecordModel({
    required this.id,
    required this.materialId,
    this.materialName = '',
    required this.type,
    required this.quantity,
    this.operatorId,
    this.relatedOrderId,
    this.notes,
    this.createdAt,
  });

  bool get isIn => type == 'in';

  factory MaterialRecordModel.fromMap(Map<String, dynamic> map) {
    return MaterialRecordModel(
      id: map['id'] as String,
      materialId: map['material_id'] as String,
      materialName: map['material_name'] as String? ?? '',
      type: map['type'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      operatorId: map['operator_id'] as String?,
      relatedOrderId: map['related_order_id'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'material_id': materialId,
    'type': type,
    'quantity': quantity,
    'operator_id': operatorId,
    'related_order_id': relatedOrderId,
    'notes': notes,
  };
}
