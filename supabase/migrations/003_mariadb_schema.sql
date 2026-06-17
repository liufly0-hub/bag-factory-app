-- 购物袋工厂生产管理系统 - MariaDB建表
USE bag_factory;

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20) UNIQUE,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(10) NOT NULL CHECK (role IN ('worker', 'boss')),
  avatar_url TEXT,
  employee_id VARCHAR(20) UNIQUE,
  hourly_wage DECIMAL(10,2) DEFAULT 0,
  piece_wage DECIMAL(10,2) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  password_hash VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS salary_settings (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  product_type VARCHAR(100) NOT NULL,
  piece_wage DECIMAL(10,2) NOT NULL,
  hourly_wage DECIMAL(10,2) DEFAULT 0,
  unit VARCHAR(10) DEFAULT '个',
  effective_date DATE NOT NULL,
  created_by VARCHAR(36) REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_product_date (product_type, effective_date)
);

CREATE TABLE IF NOT EXISTS production_records (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL REFERENCES users(id),
  product_type VARCHAR(100) NOT NULL,
  quantity INT NOT NULL CHECK (quantity >= 0),
  defect_quantity INT DEFAULT 0 CHECK (defect_quantity >= 0),
  photo_url TEXT,
  report_date DATE NOT NULL,
  status VARCHAR(10) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by VARCHAR(36) REFERENCES users(id),
  reviewed_at DATETIME,
  remark TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  order_no VARCHAR(50) UNIQUE,
  customer_name VARCHAR(200) NOT NULL,
  customer_contact VARCHAR(100),
  product_type VARCHAR(100) NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  delivered_quantity INT DEFAULT 0,
  unit_price DECIMAL(10,2),
  total_amount DECIMAL(10,2),
  deadline DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  notes TEXT,
  created_by VARCHAR(36) REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS materials (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  unit VARCHAR(20) NOT NULL,
  current_stock DECIMAL(10,2) DEFAULT 0,
  min_stock_alarm DECIMAL(10,2) DEFAULT 0,
  cost_per_unit DECIMAL(10,4),
  supplier VARCHAR(200),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS material_records (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  material_id VARCHAR(36) NOT NULL REFERENCES materials(id),
  type VARCHAR(4) NOT NULL CHECK (type IN ('in', 'out')),
  quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
  operator_id VARCHAR(36) REFERENCES users(id),
  related_order_id VARCHAR(36) REFERENCES orders(id),
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
