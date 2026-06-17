-- ============================================================
-- 购物袋工厂生产管理系统 - 数据库初始化脚本
-- Supabase / PostgreSQL
-- ============================================================

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. 用户表
-- ============================================================
CREATE TABLE users (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email         TEXT UNIQUE,
  phone         TEXT UNIQUE,
  name          TEXT NOT NULL,
  role          TEXT NOT NULL CHECK (role IN ('worker', 'boss')),
  avatar_url    TEXT,
  employee_id   TEXT UNIQUE,
  hourly_wage   DECIMAL(10,2) DEFAULT 0,
  piece_wage    DECIMAL(10,2) DEFAULT 0,
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- ============================================================
-- 2. 工价标准表
-- ============================================================
CREATE TABLE salary_settings (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_type    TEXT NOT NULL,
  piece_wage      DECIMAL(10,2) NOT NULL,
  hourly_wage     DECIMAL(10,2) DEFAULT 0,
  unit            TEXT DEFAULT '个',
  effective_date  DATE NOT NULL,
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_type, effective_date)
);
CREATE INDEX idx_salary_product ON salary_settings(product_type);
CREATE INDEX idx_salary_date ON salary_settings(effective_date DESC);

-- ============================================================
-- 3. 生产记录表
-- ============================================================
CREATE TABLE production_records (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES users(id),
  product_type    TEXT NOT NULL,
  quantity        INTEGER NOT NULL CHECK (quantity >= 0),
  defect_quantity INTEGER DEFAULT 0 CHECK (defect_quantity >= 0),
  photo_url       TEXT,
  report_date     DATE NOT NULL,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by     UUID REFERENCES users(id),
  reviewed_at     TIMESTAMPTZ,
  remark          TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_prod_user_date ON production_records(user_id, report_date);
CREATE INDEX idx_prod_date ON production_records(report_date DESC);
CREATE INDEX idx_prod_status ON production_records(status);

-- ============================================================
-- 4. 客户订单表
-- ============================================================
CREATE TABLE orders (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_no        TEXT UNIQUE,
  customer_name   TEXT NOT NULL,
  customer_contact TEXT,
  product_type    TEXT NOT NULL,
  quantity        INTEGER NOT NULL CHECK (quantity > 0),
  delivered_quantity INTEGER DEFAULT 0,
  unit_price      DECIMAL(10,2),
  total_amount    DECIMAL(10,2),
  deadline        DATE NOT NULL,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  priority        TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  notes           TEXT,
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_orders_deadline ON orders(deadline);
CREATE INDEX idx_orders_status ON orders(status);

-- ============================================================
-- 5. 物料表
-- ============================================================
CREATE TABLE materials (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name            TEXT NOT NULL,
  category        TEXT NOT NULL,
  unit            TEXT NOT NULL,
  current_stock   DECIMAL(10,2) DEFAULT 0,
  min_stock_alarm DECIMAL(10,2) DEFAULT 0,
  cost_per_unit   DECIMAL(10,4),
  supplier        TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 6. 物料出入库记录表
-- ============================================================
CREATE TABLE material_records (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  material_id     UUID NOT NULL REFERENCES materials(id),
  type            TEXT NOT NULL CHECK (type IN ('in', 'out')),
  quantity        DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
  operator_id     UUID REFERENCES users(id),
  related_order_id UUID REFERENCES orders(id),
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_mat_rec_material ON material_records(material_id);
CREATE INDEX idx_mat_rec_date ON material_records(created_at DESC);

-- ============================================================
-- Row Level Security
-- ============================================================
ALTER TABLE production_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_records ENABLE ROW LEVEL SECURITY;

-- 工人: 只能看/添加上报自己的生产记录
CREATE POLICY "worker_own_records_select" ON production_records
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "worker_own_records_insert" ON production_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 老板: 可以看/审核所有生产记录
CREATE POLICY "boss_all_records_select" ON production_records
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );
CREATE POLICY "boss_all_records_update" ON production_records
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

-- 工价: 所有人可看, 仅老板可增删改
CREATE POLICY "all_view_salary" ON salary_settings FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_salary" ON salary_settings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

-- 订单: 所有人可看, 仅老板可管理
CREATE POLICY "all_view_orders" ON orders FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_orders" ON orders
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

-- 物料: 所有人可看, 仅老板可管理
CREATE POLICY "all_view_materials" ON materials FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_materials" ON materials
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

CREATE POLICY "all_view_mat_records" ON material_records FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_mat_records" ON material_records
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );
