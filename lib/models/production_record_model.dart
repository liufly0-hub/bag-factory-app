class ProductionRecordModel {
  final String id;
  final String userId;
  final String userName;
  final String productType;
  final int quantity;
  final int defectQuantity;
  final String? photoUrl;
  final DateTime reportDate;
  final String status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? remark;
  final DateTime? createdAt;

  ProductionRecordModel({
    required this.id,
    required this.userId,
    this.userName = '',
    required this.productType,
    required this.quantity,
    this.defectQuantity = 0,
    this.photoUrl,
    required this.reportDate,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    this.remark,
    this.createdAt,
  });

  int get goodQuantity => quantity - defectQuantity;
  double get defectRate => quantity > 0 ? defectQuantity / quantity : 0;

  factory ProductionRecordModel.fromMap(Map<String, dynamic> map) {
    return ProductionRecordModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String? ?? '',
      productType: map['product_type'] as String,
      quantity: map['quantity'] as int,
      defectQuantity: map['defect_quantity'] as int? ?? 0,
      photoUrl: map['photo_url'] as String?,
      reportDate: DateTime.parse(map['report_date'] as String),
      status: map['status'] as String? ?? 'pending',
      reviewedBy: map['reviewed_by'] as String?,
      reviewedAt: map['reviewed_at'] != null ? DateTime.parse(map['reviewed_at'] as String) : null,
      remark: map['remark'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'product_type': productType,
    'quantity': quantity,
    'defect_quantity': defectQuantity,
    'photo_url': photoUrl,
    'report_date': reportDate.toIso8601String().substring(0, 10),
    'status': status,
    'remark': remark,
  };
}
