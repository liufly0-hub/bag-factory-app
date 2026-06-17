const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 3100;
const JWT_SECRET = 'bag_factory_2026_secret_key';

// 中间件
app.use(cors());
app.use(express.json());

// 数据库连接池
const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: 'factory888',
  database: 'bag_factory',
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
});

// ==================== Auth ====================
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(401).json({ error: '账号或密码错误' });

    const user = rows[0];
    if (user.password_hash && password) {
      const valid = await bcrypt.compare(password, user.password_hash);
      if (!valid) return res.status(401).json({ error: '账号或密码错误' });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    delete user.password_hash;
    res.json({ user, token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== 中间件：JWT验证 ====================
function auth(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: '未登录' });
  try {
    const decoded = jwt.verify(header.replace('Bearer ', ''), JWT_SECRET);
    req.userId = decoded.id;
    req.userRole = decoded.role;
    next();
  } catch (e) {
    res.status(401).json({ error: '登录已过期' });
  }
}

// ==================== Users / 员工管理 ====================
app.get('/api/users', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT id, email, phone, name, role, employee_id, hourly_wage, piece_wage, is_active, created_at FROM users ORDER BY name');
  res.json(rows);
});

app.get('/api/users/workers', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT id, name, employee_id FROM users WHERE role = ? AND is_active = 1', ['worker']);
  res.json(rows);
});

app.post('/api/users', auth, async (req, res) => {
  const { name, phone, email, role, employee_id } = req.body;
  const id = uuidv4();
  await pool.query('INSERT INTO users (id, name, phone, email, role, employee_id) VALUES (?, ?, ?, ?, ?, ?)', [id, name, phone, email, role || 'worker', employee_id]);
  res.json({ id, message: '创建成功' });
});

app.put('/api/users/:id/active', auth, async (req, res) => {
  await pool.query('UPDATE users SET is_active = ? WHERE id = ?', [req.body.active ? 1 : 0, req.params.id]);
  res.json({ message: 'OK' });
});

app.delete('/api/users/:id', auth, async (req, res) => {
  await pool.query('DELETE FROM users WHERE id = ?', [req.params.id]);
  res.json({ message: '已删除' });
});

// ==================== Production Records ====================
app.get('/api/production-records', auth, async (req, res) => {
  let sql = `SELECT pr.*, u.name as user_name FROM production_records pr LEFT JOIN users u ON pr.user_id = u.id WHERE 1=1`;
  const params = [];
  if (req.query.date) { sql += ' AND pr.report_date = ?'; params.push(req.query.date); }
  if (req.query.user_id) { sql += ' AND pr.user_id = ?'; params.push(req.query.user_id); }
  if (req.query.start) { sql += ' AND pr.report_date >= ?'; params.push(req.query.start); }
  if (req.query.end) { sql += ' AND pr.report_date <= ?'; params.push(req.query.end); }
  if (req.userRole === 'worker') { sql += ' AND pr.user_id = ?'; params.push(req.userId); }
  sql += ' ORDER BY pr.created_at DESC';
  const [rows] = await pool.query(sql, params);
  res.json(rows);
});

app.post('/api/production-records', auth, async (req, res) => {
  const { product_type, quantity, defect_quantity, photo_url, report_date, remark } = req.body;
  const id = uuidv4();
  const date = report_date || new Date().toISOString().split('T')[0];
  await pool.query(
    'INSERT INTO production_records (id, user_id, product_type, quantity, defect_quantity, photo_url, report_date, status, remark) VALUES (?,?,?,?,?,?,?,\'pending\',?)',
    [id, req.userId, product_type, quantity, defect_quantity || 0, photo_url || null, date, remark || null]
  );
  res.json({ id, message: '上报成功' });
});

app.put('/api/production-records/:id/review', auth, async (req, res) => {
  if (req.userRole !== 'boss') return res.status(403).json({ error: '仅老板可审核' });
  const { status, remark } = req.body;
  await pool.query('UPDATE production_records SET status=?, reviewed_by=?, reviewed_at=NOW(), remark=? WHERE id=?', [status, req.userId, remark || null, req.params.id]);
  res.json({ message: status === 'approved' ? '已审核通过' : '已驳回' });
});

// ==================== Orders ====================
app.get('/api/orders', auth, async (req, res) => {
  let sql = 'SELECT * FROM orders WHERE 1=1';
  const params = [];
  if (req.query.status) { sql += ' AND status = ?'; params.push(req.query.status); }
  sql += ' ORDER BY deadline ASC';
  const [rows] = await pool.query(sql, params);
  res.json(rows);
});

app.get('/api/orders/:id', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
  res.json(rows[0] || null);
});

app.post('/api/orders', auth, async (req, res) => {
  const { customer_name, customer_contact, product_type, quantity, unit_price, deadline, priority, notes } = req.body;
  const id = uuidv4();
  await pool.query(
    'INSERT INTO orders (id, order_no, customer_name, customer_contact, product_type, quantity, unit_price, deadline, priority, notes, created_by) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    [id, `ORD-${Date.now()}`, customer_name, customer_contact, product_type, quantity, unit_price, deadline, priority || 'normal', notes, req.userId]
  );
  res.json({ id, message: '创建成功' });
});

app.put('/api/orders/:id', auth, async (req, res) => {
  const { customer_name, product_type, quantity, delivered_quantity, deadline, status, priority } = req.body;
  await pool.query(
    'UPDATE orders SET customer_name=?, product_type=?, quantity=?, delivered_quantity=?, deadline=?, status=?, priority=? WHERE id=?',
    [customer_name, product_type, quantity, delivered_quantity || 0, deadline, status || 'pending', priority || 'normal', req.params.id]
  );
  res.json({ message: '更新成功' });
});

app.delete('/api/orders/:id', auth, async (req, res) => {
  await pool.query('DELETE FROM orders WHERE id = ?', [req.params.id]);
  res.json({ message: '已删除' });
});

// ==================== Salary Settings ====================
app.get('/api/salary-settings', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM salary_settings ORDER BY effective_date DESC');
  res.json(rows);
});

app.post('/api/salary-settings', auth, async (req, res) => {
  if (req.userRole !== 'boss') return res.status(403).json({ error: '仅老板可操作' });
  const { product_type, piece_wage, hourly_wage, effective_date } = req.body;
  const id = uuidv4();
  await pool.query('INSERT INTO salary_settings (id, product_type, piece_wage, hourly_wage, effective_date, created_by) VALUES (?,?,?,?,?,?)',
    [id, product_type, piece_wage, hourly_wage || 0, effective_date, req.userId]);
  res.json({ id, message: '设置成功' });
});

// ==================== Materials ====================
app.get('/api/materials', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM materials ORDER BY name');
  res.json(rows);
});

app.post('/api/materials', auth, async (req, res) => {
  const { name, category, unit, current_stock, min_stock_alarm, cost_per_unit, supplier } = req.body;
  const id = uuidv4();
  await pool.query('INSERT INTO materials (id, name, category, unit, current_stock, min_stock_alarm, cost_per_unit, supplier) VALUES (?,?,?,?,?,?,?,?)',
    [id, name, category, unit, current_stock || 0, min_stock_alarm || 0, cost_per_unit, supplier]);
  res.json({ id, message: '添加成功' });
});

app.post('/api/material-records', auth, async (req, res) => {
  const { material_id, type, quantity, notes, related_order_id } = req.body;
  const id = uuidv4();
  await pool.query('INSERT INTO material_records (id, material_id, type, quantity, operator_id, related_order_id, notes) VALUES (?,?,?,?,?,?,?)',
    [id, material_id, type, quantity, req.userId, related_order_id, notes]);
  // Update stock
  const delta = type === 'in' ? quantity : -quantity;
  await pool.query('UPDATE materials SET current_stock = current_stock + ? WHERE id = ?', [delta, material_id]);
  res.json({ id, message: '记录成功' });
});

app.get('/api/material-records/:material_id', auth, async (req, res) => {
  const [rows] = await pool.query('SELECT mr.*, m.name as material_name FROM material_records mr JOIN materials m ON mr.material_id = m.id WHERE mr.material_id = ? ORDER BY mr.created_at DESC', [req.params.material_id]);
  res.json(rows);
});

// ==================== 初始化测试数据 ====================
app.post('/api/init', async (req, res) => {
  // 创建老板账号
  const bossId = uuidv4();
  const hash = await bcrypt.hash('boss8888', 10);
  await pool.query('INSERT IGNORE INTO users (id, email, name, role, employee_id, password_hash) VALUES (?,?,?,?,?,?)',
    [bossId, '3389716868@qq.com', '老板', 'boss', 'B001', hash]);

  // 创建工人
  const workers = [
    { name: '张三', id: uuidv4(), emp: 'W001' },
    { name: '李四', id: uuidv4(), emp: 'W002' },
  ];
  for (const w of workers) {
    await pool.query('INSERT IGNORE INTO users (id, name, role, employee_id) VALUES (?,?,?,?)', [w.id, w.name, 'worker', w.emp]);
  }

  // 工价
  const prices = [
    ['百褶折叠购物袋', 0.50],
    ['平口折叠购物袋', 0.40],
    ['帆布折叠购物袋', 0.80],
    ['涤纶折叠购物袋', 0.60],
    ['无纺布购物袋', 0.30],
  ];
  for (const [p, w] of prices) {
    const sid = uuidv4();
    await pool.query('INSERT IGNORE INTO salary_settings (id, product_type, piece_wage, effective_date, created_by) VALUES (?,?,?,CURDATE(),?)', [sid, p, w, bossId]);
  }

  // 订单
  const oid = uuidv4();
  await pool.query("INSERT INTO orders (id, customer_name, product_type, quantity, deadline, status, priority, created_by) VALUES (?,?,?,?,DATE_ADD(CURDATE(), INTERVAL 30 DAY),'in_progress','normal',?)",
    [oid, '测试客户', '百褶折叠购物袋', 10000, bossId]);

  res.json({ message: '初始化完成', bossEmail: '3389716868@qq.com', bossPassword: 'boss8888' });
});

// ==================== 启动 ====================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`工厂API运行在 http://0.0.0.0:${PORT}`);
  console.log(`登录账号: boss8888`);
});
