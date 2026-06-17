class SalarySettingModel {
  final String id;
  final String productType;
  final double pieceWage;
  final double hourlyWage;
  final String unit;
  final DateTime effectiveDate;
  final String? createdBy;

  SalarySettingModel({
    required this.id,
    required this.productType,
    required this.pieceWage,
    this.hourlyWage = 0,
    this.unit = '个',
    required this.effectiveDate,
    this.createdBy,
  });

  factory SalarySettingModel.fromMap(Map<String, dynamic> map) {
    return SalarySettingModel(
      id: map['id'] as String,
      productType: map['product_type'] as String,
      pieceWage: (map['piece_wage'] as num).toDouble(),
      hourlyWage: (map['hourly_wage'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '个',
      effectiveDate: DateTime.parse(map['effective_date'] as String),
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'product_type': productType,
    'piece_wage': pieceWage,
    'hourly_wage': hourlyWage,
    'unit': unit,
    'effective_date': effectiveDate.toIso8601String().substring(0, 10),
  };
}
