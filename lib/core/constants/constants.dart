/// 产品类型枚举
class ProductTypes {
  static const List<String> all = [
    '百褶折叠购物袋',
    '平口折叠购物袋',
    '帆布折叠购物袋',
    '涤纶折叠购物袋',
    '无纺布购物袋',
    '拉链背包',
    '双肩背包',
    '手提袋',
    '收纳袋',
    '其他',
  ];

  static const Map<String, String> units = {
    '百褶折叠购物袋': '个',
    '平口折叠购物袋': '个',
    '帆布折叠购物袋': '个',
    '涤纶折叠购物袋': '个',
    '无纺布购物袋': '个',
    '拉链背包': '个',
    '双肩背包': '个',
    '手提袋': '个',
    '收纳袋': '个',
    '其他': '个',
  };
}

/// 生产记录状态
class RecordStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static const List<String> all = [pending, approved, rejected];
}

/// 订单状态
class OrderStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static const List<String> all = [pending, inProgress, completed, cancelled];
}

/// 优先级
class Priority {
  static const String low = 'low';
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'urgent';

  static const List<String> all = [low, normal, high, urgent];
}

/// 用户角色
class UserRole {
  static const String worker = 'worker';
  static const String boss = 'boss';

  static const List<String> all = [worker, boss];
}

/// 物料类别
class MaterialCategory {
  static const String raw = '原料';
  static const String auxiliary = '辅料';
  static const String packaging = '包装';

  static const List<String> all = [raw, auxiliary, packaging];
}
