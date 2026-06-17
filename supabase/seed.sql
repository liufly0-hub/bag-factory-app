-- ============================================================
-- 测试数据
-- ============================================================

-- 老板账号 (密码: boss123456)
INSERT INTO auth.users (id, email, encrypted_password) VALUES
  ('00000000-0000-0000-0000-000000000001', 'boss@factory.com', '$2a$10$...'),
  ('00000000-0000-0000-0000-000000000002', 'worker1@factory.com', '$2a$10$...'),
  ('00000000-0000-0000-0000-000000000003', 'worker2@factory.com', '$2a$10$...');

INSERT INTO users (id, name, phone, role, employee_id, is_active) VALUES
  ('00000000-0000-0000-0000-000000000001', '老板', '13800000001', 'boss', 'B001', TRUE),
  ('00000000-0000-0000-0000-000000000002', '张三', '13800000002', 'worker', 'W001', TRUE),
  ('00000000-0000-0000-0000-000000000003', '李四', '13800000003', 'worker', 'W002', TRUE);

-- 工价
INSERT INTO salary_settings (product_type, piece_wage, unit, effective_date, created_by) VALUES
  ('背心袋', 0.05, '个', CURRENT_DATE, '00000000-0000-0000-0000-000000000001'),
  ('平口袋', 0.08, '个', CURRENT_DATE, '00000000-0000-0000-0000-000000000001'),
  ('折叠购物袋', 0.50, '个', CURRENT_DATE, '00000000-0000-0000-0000-000000000001'),
  ('黄麻包', 1.50, '个', CURRENT_DATE, '00000000-0000-0000-0000-000000000001');

-- 示例订单
INSERT INTO orders (order_no, customer_name, product_type, quantity, deadline, status, priority) VALUES
  ('ORD-2026-001', '杭州贸易公司', '背心袋', 50000, CURRENT_DATE + 20, 'in_progress', 'high'),
  ('ORD-2026-002', '上海超市', '折叠购物袋', 10000, CURRENT_DATE + 30, 'pending', 'normal'),
  ('ORD-2026-003', '广州礼品公司', '黄麻包', 2000, CURRENT_DATE + 45, 'pending', 'low');

-- 示例物料
INSERT INTO materials (name, category, unit, current_stock, min_stock_alarm) VALUES
  ('HDPE塑料粒子', '原料', '公斤', 500, 100),
  ('无纺布', '原料', '卷', 20, 5),
  ('黄麻布料', '原料', '米', 300, 50),
  ('纸箱', '包装', '个', 200, 50);
