import express from 'express'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import db from '../config/db.js'

const router = express.Router()

// 登录
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body
    
    // 查询用户
    const [users] = await db.query(
      'SELECT * FROM users WHERE email = ? AND status = 1',
      [email]
    )
    
    if (users.length === 0) {
      return res.json({
        code: 400,
        message: '用户不存在或已被禁用'
      })
    }
    
    const user = users[0]
    
    // 验证密码（简单比对，实际应该用 bcrypt）
    if (password !== user.password) {
      return res.json({
        code: 400,
        message: '密码错误'
      })
    }
    
    // 生成 token
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        realName: user.real_name,
        role: user.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    )
    
    res.json({
      code: 200,
      message: '登录成功',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          realName: user.real_name,
          phone: user.phone,
          role: user.role,
          avatar: user.avatar_url,
          createdAt: user.created_at
        }
      }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

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
      return res.json({
        code: 400,
        message: '该邮箱已被注册'
      })
    }
    
    // 插入用户,默认角色为管理员
    const [result] = await db.query(
      'INSERT INTO users (email, password, real_name, phone, role) VALUES (?, ?, ?, ?, ?)',
      [email, password, realName, phone, 'admin']
    )
    
    res.json({
      code: 200,
      message: '注册成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 更新用户信息
router.put('/profile', async (req, res) => {
  try {
    const { userId, realName, phone, avatar } = req.body
    
    if (!userId) {
      return res.json({
        code: 400,
        message: '用户ID不能为空'
      })
    }
    
    // 更新用户信息
    await db.query(
      'UPDATE users SET real_name = ?, phone = ?, avatar_url = ? WHERE id = ?',
      [realName, phone, avatar, userId]
    )
    
    // 查询更新后的用户信息
    const [users] = await db.query(
      'SELECT id, email, real_name, phone, role, avatar_url, created_at FROM users WHERE id = ?',
      [userId]
    )
    
    if (users.length === 0) {
      return res.json({
        code: 400,
        message: '用户不存在'
      })
    }
    
    const user = users[0]
    
    res.json({
      code: 200,
      message: '保存成功',
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
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 修改密码
router.put('/password', async (req, res) => {
  try {
    const { userId, oldPassword, newPassword } = req.body
    
    if (!userId || !oldPassword || !newPassword) {
      return res.json({
        code: 400,
        message: '参数不完整'
      })
    }
    
    // 查询用户当前密码
    const [users] = await db.query(
      'SELECT password FROM users WHERE id = ?',
      [userId]
    )
    
    if (users.length === 0) {
      return res.json({
        code: 400,
        message: '用户不存在'
      })
    }
    
    const user = users[0]
    
    // 验证原密码
    if (oldPassword !== user.password) {
      return res.json({
        code: 400,
        message: '原密码错误'
      })
    }
    
    // 更新密码
    await db.query(
      'UPDATE users SET password = ? WHERE id = ?',
      [newPassword, userId]
    )
    
    res.json({
      code: 200,
      message: '密码修改成功'
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

export default router
