class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String role; // 'worker' | 'boss'
  final String? avatarUrl;
  final String? employeeId;
  final double hourlyWage;
  final double pieceWage;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.employeeId,
    this.hourlyWage = 0,
    this.pieceWage = 0,
    this.isActive = true,
    this.createdAt,
  });

  bool get isBoss => role == 'boss';
  bool get isWorker => role == 'worker';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      name: map['name'] as String,
      role: map['role'] as String,
      avatarUrl: map['avatar_url'] as String?,
      employeeId: map['employee_id'] as String?,
      hourlyWage: (map['hourly_wage'] as num?)?.toDouble() ?? 0,
      pieceWage: (map['piece_wage'] as num?)?.toDouble() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'phone': phone,
    'name': name,
    'role': role,
    'avatar_url': avatarUrl,
    'employee_id': employeeId,
    'hourly_wage': hourlyWage,
    'piece_wage': pieceWage,
    'is_active': isActive,
  };
}
