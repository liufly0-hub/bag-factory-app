class OrderModel {
  final String id;
  final String? orderNo;
  final String customerName;
  final String? customerContact;
  final String productType;
  final int quantity;
  final int deliveredQuantity;
  final double? unitPrice;
  final double? totalAmount;
  final DateTime deadline;
  final String status;
  final String priority;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    this.orderNo,
    required this.customerName,
    this.customerContact,
    required this.productType,
    required this.quantity,
    this.deliveredQuantity = 0,
    this.unitPrice,
    this.totalAmount,
    required this.deadline,
    this.status = 'pending',
    this.priority = 'normal',
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  int get remainingQuantity => quantity - deliveredQuantity;
  double get progress => quantity > 0 ? deliveredQuantity / quantity : 0;
  bool get isOverdue => deadline.isBefore(DateTime.now()) && status != 'completed';

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderNo: map['order_no'] as String?,
      customerName: map['customer_name'] as String,
      customerContact: map['customer_contact'] as String?,
      productType: map['product_type'] as String,
      quantity: map['quantity'] as int,
      deliveredQuantity: map['delivered_quantity'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble(),
      totalAmount: (map['total_amount'] as num?)?.toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      status: map['status'] as String? ?? 'pending',
      priority: map['priority'] as String? ?? 'normal',
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'order_no': orderNo,
    'customer_name': customerName,
    'customer_contact': customerContact,
    'product_type': productType,
    'quantity': quantity,
    'delivered_quantity': deliveredQuantity,
    'unit_price': unitPrice,
    'total_amount': totalAmount,
    'deadline': deadline.toIso8601String().substring(0, 10),
    'status': status,
    'priority': priority,
    'notes': notes,
  };
}
