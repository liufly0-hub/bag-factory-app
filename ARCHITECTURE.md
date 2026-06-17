# 购物袋工厂生产管理系统 — 架构设计文档 v1.0

---

## 1. 技术选型

### 推荐方案：Flutter + Supabase

| 层级 | 技术 | 选型理由 |
|------|------|---------|
| **前端框架** | Flutter 3.x | • 一套代码跑 iOS + Android<br>• 原生级性能，UI灵活<br>• 适合做大按钮/大字体的极简工人端<br>• 开发速度快 |
| **后端/BaaS** | Supabase | • 开箱即用的 PostgreSQL 数据库<br>• 内置用户认证（邮箱/手机/扫码登录）<br>• 内置文件存储（拍照上传）<br>• Realtime 订阅（看板数据实时刷新）<br>• 免费额度足够工厂内部使用 |
| **状态管理** | Riverpod | 轻量、类型安全、易测试 |
| **图表** | fl_chart | Flutter 上最成熟的图表库 |
| **本地缓存** | hive / isar | 离线时暂存生产数据，车间信号差也不丢数据 |

### 为什么不选其他方案
| 方案 | 问题 |
|------|------|
| React Native + Node.js | 需自建后端、部署服务器、维护成本高 |
| 微信小程序 | 功能受限、拍照/存储/权限都受微信约束 |
| 纯Web PWA | 无法调用摄像头、离线能力差 |
| 原生Android+iOS | 两套代码，开发周期长 |

---

## 2. 项目目录结构

```
bag_factory_app/
├── lib/
│   ├── main.dart                    # 入口：初始化Supabase、路由配置
│   ├── app.dart                     # MaterialApp + 主题配置
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── supabase_config.dart   # Supabase URL & Anon Key
│   │   │   └── theme.dart             # 极简主题（大按钮、大字体）
│   │   ├── constants/
│   │   │   └── constants.dart         # 产品类型枚举、状态常量
│   │   └── utils/
│   │       ├── date_utils.dart        # 日期工具函数
│   │       ├── number_utils.dart      # 金额/数量格式化
│   │       └── image_utils.dart       # 图片压缩/上传工具
│   │
│   ├── models/                        # 数据模型
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── production_record_model.dart
│   │   ├── order_model.dart
│   │   ├── material_model.dart
│   │   ├── salary_setting_model.dart
│   │   └── wage_calculation_model.dart
│   │
│   ├── providers/                     # Riverpod 状态管理
│   │   ├── auth_provider.dart
│   │   ├── production_provider.dart
│   │   ├── order_provider.dart
│   │   ├── salary_provider.dart
│   │   ├── dashboard_provider.dart
│   │   └── material_provider.dart
│   │
│   ├── repositories/                  # 数据仓库层
│   │   ├── auth_repository.dart
│   │   ├── production_repository.dart
│   │   ├── order_repository.dart
│   │   ├── salary_repository.dart
│   │   ├── material_repository.dart
│   │   └── employee_repository.dart
│   │
│   ├── services/                      # 业务逻辑层
│   │   ├── wage_calculator.dart       # 薪酬计算引擎
│   │   ├── deadline_estimator.dart    # 工期推算引擎
│   │   └── dashboard_aggregator.dart  # 看板数据聚合
│   │
│   ├── screens/                       # 页面
│   │   ├── auth/
│   │   │   └── login_screen.dart      # 登录页（支持扫码登录）
│   │   │
│   │   ├── worker/                    # ⭐ 工人端（极简大字体）
│   │   │   ├── worker_home_screen.dart        # 首页：今日上报、我的工资
│   │   │   ├── production_report_screen.dart  # 生产上报（日期/产品/数量/次品/拍照）
│   │   │   ├── my_wages_screen.dart           # 我的工资（日/周/月）
│   │   │   └── my_schedule_screen.dart        # 我的排班与工期
│   │   │
│   │   └── boss/                     # 老板端
│   │       ├── boss_home_screen.dart           # 首页：数据概览
│   │       ├── dashboard_screen.dart           # 数据看板（图表）
│   │       ├── audit_records_screen.dart       # 审核工人上报数据
│   │       ├── order_management_screen.dart    # 订单管理
│   │       ├── material_management_screen.dart # 物料管理
│   │       ├── employee_management_screen.dart # 员工管理
│   │       ├── salary_settings_screen.dart     # 工价标准设置
│   │       └── wage_report_screen.dart         # 全厂薪酬报表
│   │
│   ├── widgets/                       # 可复用组件
│   │   ├── big_button.dart            # 超大按钮（工人端专用）
│   │   ├── big_input_field.dart       # 大字号输入框
│   │   ├── photo_capture_widget.dart  # 拍照组件
│   │   ├── loading_overlay.dart       # 加载遮罩
│   │   ├── empty_state.dart           # 空状态
│   │   └── error_state.dart           # 错误状态
│   │
│   └── router/
│       └── app_router.dart            # 路由配置（按角色分流）
│
├── supabase/
│   ├── migrations/                    # 数据库迁移脚本
│   │   └── 001_initial_schema.sql
│   └── seed.sql                       # 测试数据
│
├── test/
│   ├── services/
│   │   └── wage_calculator_test.dart
│   ├── repositories/
│   └── widgets/
│
├── pubspec.yaml
└── README.md
```

---

## 3. 数据库设计（PostgreSQL / Supabase）

### 3.1 ER 图（文字版）

```
┌──────────────────┐       ┌─────────────────────┐
│     users        │       │   production_records │
│──────────────────│       │─────────────────────│
│ id (uuid) PK     │──1:N──│ id (uuid) PK        │
│ email            │       │ user_id FK          │
│ phone            │       │ product_type         │
│ name             │       │ quantity             │
│ role (worker|boss)│      │ defect_quantity      │
│ avatar_url       │       │ photo_url            │
│ hourly_wage      │       │ report_date          │
│ is_active        │       │ status (pending|approved|rejected)
│ created_at       │       │ reviewed_by FK       │
│                  │       │ reviewed_at          │
│                  │       │ created_at           │
└──────────────────┘       └─────────────────────┘
        │ 1                           │
        │                             │
        │ 1:N                         │ N:1
        │                             │
┌──────────────────┐       ┌─────────────────────┐
│   salary_settings│       │    orders           │
│──────────────────│       │─────────────────────│
│ id (uuid) PK     │       │ id (uuid) PK        │
│ product_type     │       │ customer_name        │
│ piece_wage       │       │ product_type         │
│ hourly_wage      │       │ quantity             │
│ effective_date   │       │ delivered_quantity   │
│ created_by FK    │       │ deadline             │
│ created_at       │       │ status               │
└──────────────────┘       │ priority             │
                            │ notes                │
┌──────────────────┐       │ created_at           │
│   materials      │       └─────────────────────┘
│──────────────────│
│ id (uuid) PK     │       ┌─────────────────────┐
│ name             │       │   material_records   │
│ category         │       │─────────────────────│
│ unit             │       │ id (uuid) PK        │
│ current_stock    │       │ material_id FK       │
│ min_stock_alarm  │       │ type (in|out)        │
│ created_at       │       │ quantity             │
│ updated_at       │       │ operator FK          │
└──────────────────┘       │ notes                │
                            │ created_at           │
                            └─────────────────────┘
```

### 3.2 完整表结构（SQL）

```sql
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
  -- 工人专属字段
  hourly_wage   DECIMAL(10,2) DEFAULT 0,        -- 时薪（元/小时）
  piece_wage    DECIMAL(10,2) DEFAULT 0,         -- 计件单价默认值
  employee_id   TEXT UNIQUE,                     -- 工号
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- ============================================================
-- 2. 工价标准表（老板设置）
-- ============================================================
CREATE TABLE salary_settings (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_type    TEXT NOT NULL,                  -- 产品类型
  piece_wage      DECIMAL(10,2) NOT NULL,        -- 计件单价（元/个）
  hourly_wage     DECIMAL(10,2) DEFAULT 0,       -- 时薪（备用）
  unit            TEXT DEFAULT '个',              -- 单位
  effective_date  DATE NOT NULL,                  -- 生效日期
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  
  -- 同一产品同一日期只能有一条工价
  UNIQUE(product_type, effective_date)
);

CREATE INDEX idx_salary_product ON salary_settings(product_type);
CREATE INDEX idx_salary_date ON salary_settings(effective_date DESC);

-- ============================================================
-- 3. 生产记录表（工人上报）
-- ============================================================
CREATE TABLE production_records (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES users(id),
  product_type    TEXT NOT NULL,                  -- 产品类型
  quantity        INTEGER NOT NULL CHECK (quantity >= 0),        -- 生产数量
  defect_quantity INTEGER DEFAULT 0 CHECK (defect_quantity >= 0), -- 次品数量
  photo_url       TEXT,                           -- 拍照上传URL
  report_date     DATE NOT NULL,                  -- 上报日期
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by     UUID REFERENCES users(id),      -- 审核人
  reviewed_at     TIMESTAMPTZ,                    -- 审核时间
  remark          TEXT,                            -- 备注
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_prod_user_date ON production_records(user_id, report_date);
CREATE INDEX idx_prod_date ON production_records(report_date DESC);
CREATE INDEX idx_prod_status ON production_records(status);
CREATE INDEX idx_prod_product ON production_records(product_type);

-- ============================================================
-- 4. 客户订单表
-- ============================================================
CREATE TABLE orders (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_no        TEXT UNIQUE,                   -- 订单编号
  customer_name   TEXT NOT NULL,                  -- 客户名称
  customer_contact TEXT,                          -- 联系方式
  product_type    TEXT NOT NULL,                  -- 产品类型
  quantity        INTEGER NOT NULL CHECK (quantity > 0),        -- 订单总数量
  delivered_quantity INTEGER DEFAULT 0,           -- 已交付数量
  unit_price      DECIMAL(10,2),                 -- 单价（给客户的价格）
  total_amount    DECIMAL(10,2),                 -- 总金额
  deadline        DATE NOT NULL,                  -- 交期
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  priority        TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  notes           TEXT,
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_deadline ON orders(deadline);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_customer ON orders(customer_name);

-- ============================================================
-- 5. 物料/原材料表
-- ============================================================
CREATE TABLE materials (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name            TEXT NOT NULL,                  -- 物料名称（如：HDPE塑料粒子）
  category        TEXT NOT NULL,                  -- 类别（原料/辅料/包装）
  unit            TEXT NOT NULL,                  -- 单位（公斤/卷/个）
  current_stock   DECIMAL(10,2) DEFAULT 0,        -- 当前库存
  min_stock_alarm DECIMAL(10,2) DEFAULT 0,        -- 最低库存预警
  cost_per_unit   DECIMAL(10,4),                 -- 单价
  supplier        TEXT,                           -- 供应商
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_materials_category ON materials(category);

-- ============================================================
-- 6. 物料出入库记录表
-- ============================================================
CREATE TABLE material_records (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  material_id     UUID NOT NULL REFERENCES materials(id),
  type            TEXT NOT NULL CHECK (type IN ('in', 'out')),  -- 入库/出库
  quantity        DECIMAL(10,2) NOT NULL CHECK (quantity > 0),  -- 数量
  operator_id     UUID REFERENCES users(id),      -- 操作人
  related_order_id UUID REFERENCES orders(id),    -- 关联订单（可选）
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_mat_rec_material ON material_records(material_id);
CREATE INDEX idx_mat_rec_date ON material_records(created_at DESC);
CREATE INDEX idx_mat_rec_type ON material_records(type);

-- ============================================================
-- 7. 照片/附件存储表（Supabase Storage 配合使用）
-- ============================================================
-- 照片存在 Supabase Storage 的 production-photos 桶中
-- 在 production_records.photo_url 中存储公开URL

-- ============================================================
-- Row Level Security (RLS) 策略
-- ============================================================

-- 用户只能看自己的数据（工人）
ALTER TABLE production_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "workers_view_own_records" ON production_records
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "workers_insert_own_records" ON production_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "boss_view_all_records" ON production_records
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );
CREATE POLICY "boss_review_records" ON production_records
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

-- 工价标准：老板读写，工人只读
ALTER TABLE salary_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "workers_view_salary" ON salary_settings
  FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_salary" ON salary_settings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );

-- 订单：老板全部权限，工人只读
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "workers_view_orders" ON orders
  FOR SELECT USING (TRUE);
CREATE POLICY "boss_manage_orders" ON orders
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'boss')
  );
```

---

## 4. 核心业务逻辑说明

### 4.1 薪酬计算逻辑（Wage Calculator）

```
日薪 = SUM(当天各产品上报数量 × 对应产品计件单价)
周薪 = SUM(本周7天日薪)
月薪 = SUM(本月所有已审核的计件工资)

计件工资 = 上报数量 × 产品单价
良品工资 = (生产数量 - 次品数量) × 产品单价
按工时工资 = 工时 × 时薪（备用方案，用于非计件工种）
```

### 4.2 工期推算逻辑（Deadline Estimator）

```
日均产能 = 最近7天该产品平均日产量（取已审核数据）
预计完工天数 = (订单总数量 - 已交付数量) / 日均产能
预计完工日期 = 今天 + 预计完工天数
逾期预警 = 预计完工日期 > 订单交期（触发红色警报）
```

---

## 5. 交互设计原则

### 工人端
- **字体最小值 18sp**，按钮高度 ≥ 56dp
- 上报流程不超过 3 步（选产品 → 填数量 → 拍照确认）
- 支持离线暂存（车间信号差时存本地，有网自动同步）
- 每个操作都有大号确认弹窗，防止误触

### 老板端
- 看板默认显示「今日全厂」数据
- 审核列表按时间倒序，红色标记异常（次品率>10%）
- 图表支持按日/周/月切换

---

## 6. 部署方案

```
Supabase Cloud（免费版）
  ├── PostgreSQL 数据库（500MB免费）
  ├── 用户认证（5万月活免费）
  ├── 文件存储（1GB免费）
  └── Realtime 订阅

Flutter App
  ├── Android APK（直接发到工人手机安装）
  └── iOS（TestFlight 分发或企业证书签名）

无需自建服务器！
```

---

## 7. 开发路线图

| 阶段 | 内容 | 预估工期 |
|------|------|---------|
| Phase 1 | 数据库建表 + Supabase 配置 + 用户认证 | 1天 |
| Phase 2 | 工人端：生产上报 + 工资查看 + 离线缓存 | 2天 |
| Phase 3 | 老板端：数据审核 + 工价设置 + 员工管理 | 2天 |
| Phase 4 | 订单管理 + 物料管理 | 2天 |
| Phase 5 | 数据看板 + 图表 + 工期推算 | 1天 |
| Phase 6 | 测试 + 打包分发 | 1天 |
| **总计** | | **9天** |

---

> 以上是完整的架构设计方案。如果你确认没有问题，下一步我将：
> 1. 初始化 Flutter 项目 + Supabase 项目
> 2. 执行数据库建表 SQL
> 3. 开始生成「工人端生产上报」页面的完整代码
