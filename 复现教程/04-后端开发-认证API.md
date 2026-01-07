# 第四步：后端开发 - 认证API

## 1. 创建认证路由

创建 `routes/auth.js`：

```javascript
import express from 'express'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 注册
router.post('/register', async (req, res) => {
  try {
    const { email, password, realName, phone } = req.body
    
    // 检查邮箱是否已存在
    const [existing] = await db.query(
      'SELECT id FROM users WHERE email = ?', 
      [email]
    )
    
    if (existing.length > 0) {
      return res.json({ code: 400, message: '邮箱已被注册' })
    }
    
    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10)
    
    // 插入用户
    const [result] = await db.query(
      'INSERT INTO users (email, password, real_name, phone, role) VALUES (?, ?, ?, ?, ?)',
      [email, hashedPassword, realName, phone, 'admin']
    )
    
    res.json({ code: 200, message: '注册成功', data: { id: result.insertId } })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

// 登录
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body
    
    // 查询用户
    const [users] = await db.query(
      'SELECT * FROM users WHERE email = ?', 
      [email]
    )
    
    if (users.length === 0) {
      return res.json({ code: 400, message: '用户不存在' })
    }
    
    const user = users[0]
    
    // 验证密码
    const isValid = await bcrypt.compare(password, user.password)
    
    if (!isValid) {
      return res.json({ code: 400, message: '密码错误' })
    }
    
    // 生成token
    const token = jwt.sign(
      { id: user.id, email: user.email, realName: user.real_name },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    )
    
    res.json({
      code: 200,
      message: '登录成功',
      data: {
        token,
        userInfo: {
          id: user.id,
          email: user.email,
          realName: user.real_name,
          phone: user.phone,
          role: user.role,
          avatar: user.avatar_url
        }
      }
    })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

// 获取当前用户信息
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT id, email, real_name, phone, role, avatar_url, created_at FROM users WHERE id = ?',
      [req.user.id]
    )
    
    if (users.length === 0) {
      return res.json({ code: 404, message: '用户不存在' })
    }
    
    const user = users[0]
    res.json({
      code: 200,
      data: {
        id: user.id,
        email: user.email,
        realName: user.real_name,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar_url,
        createdAt: user.created_at
      }
    })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

export default router
```

## 2. 在主文件中注册路由

修改 `index.js`，添加：

```javascript
import authRoutes from './routes/auth.js'

// 在 app.use(express.json()) 之后添加
app.use('/api/auth', authRoutes)
```

## 3. 测试API

### 3.1 测试注册
使用Postman或curl：
```bash
POST http://localhost:3001/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "123456",
  "realName": "测试用户",
  "phone": "13800138000"
}
```

### 3.2 测试登录
```bash
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "123456"
}
```

应该返回token和用户信息

### 3.3 测试获取用户信息
```bash
GET http://localhost:3001/api/auth/me
Authorization: Bearer <你的token>
```

## 下一步

认证API完成后，继续阅读 `05-后端开发-学生API.md`
