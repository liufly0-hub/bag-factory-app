#!/bin/bash
# 工厂APP - 直接插入种子数据（跳过API init）
mysql -u root <<'EOF'
USE bag_factory;

-- 老板账号 boss@aos.com / boss8888
INSERT INTO users (id, email, name, role, employee_id) VALUES
('boss-001', '3389716868@qq.com', '老板', 'boss', 'B001')
ON DUPLICATE KEY UPDATE name=name;

-- 工人
INSERT INTO users (id, name, role, employee_id, is_active) VALUES
('worker-001', '张三', 'worker', 'W001', 1),
('worker-002', '李四', 'worker', 'W002', 1),
('worker-003', '王五', 'worker', 'W003', 1)
ON DUPLICATE KEY UPDATE name=name;

-- 工价
INSERT INTO salary_settings (id, product_type, piece_wage, effective_date, created_by) VALUES
('sal-001', '百褶折叠购物袋', 0.50, CURDATE(), 'boss-001'),
('sal-002', '平口折叠购物袋', 0.40, CURDATE(), 'boss-001'),
('sal-003', '帆布折叠购物袋', 0.80, CURDATE(), 'boss-001'),
('sal-004', '涤纶折叠购物袋', 0.60, CURDATE(), 'boss-001'),
('sal-005', '无纺布购物袋', 0.30, CURDATE(), 'boss-001')
ON DUPLICATE KEY UPDATE piece_wage=VALUES(piece_wage);

-- 订单
INSERT INTO orders (id, customer_name, product_type, quantity, deadline, status, priority, created_by) VALUES
('ord-001', '测试客户A', '百褶折叠购物袋', 10000, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'in_progress', 'normal', 'boss-001'),
('ord-002', '测试客户B', '帆布折叠购物袋', 5000, DATE_ADD(CURDATE(), INTERVAL 45 DAY), 'pending', 'high', 'boss-001')
ON DUPLICATE KEY UPDATE customer_name=customer_name;

-- 物料
INSERT INTO materials (id, name, category, unit, current_stock, min_stock_alarm, supplier) VALUES
('mat-001', 'HDPE塑料粒子', '原料', '公斤', 500, 100, '中石化'),
('mat-002', '涤纶布', '原料', '米', 300, 50, '绍兴纺织'),
('mat-003', '拉链', '辅料', '条', 1000, 200, '温州拉链厂'),
('mat-004', '纸箱', '包装', '个', 200, 50, '义乌包装厂')
ON DUPLICATE KEY UPDATE name=name;

SELECT CONCAT('✅ 插入了 ', COUNT(*), ' 条种子数据') FROM users;
EOF
