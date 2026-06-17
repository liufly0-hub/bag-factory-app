-- ============================================================
-- 购物袋工厂生产管理系统 - 建表SQL（简化版，无RLS）
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. 用户表
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

-- 2. 工价标准表
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

-- 3. 生产记录表
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

-- 4. 客户订单表
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

-- 5. 物料表
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

-- 6. 物料出入库记录表
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
