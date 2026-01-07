import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取通知列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [notifications] = await db.query(`
      SELECT * FROM notifications
      ORDER BY created_at DESC
      LIMIT 100
    `)
    
    res.json({
      code: 200,
      data: notifications.map(n => ({
        id: n.id,
        title: n.title,
        content: n.content,
        type: n.type,
        senderId: n.sender_id,
        senderName: n.sender_name,
        receiverRole: n.receiver_role,
        fileUrl: n.file_url,
        createdAt: n.created_at
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 发布通知
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { title, content, type, receiverRole } = req.body
    const senderId = req.user.id
    
    // 获取发送人姓名
    const [sender] = await db.query('SELECT real_name FROM users WHERE id = ?', [senderId])
    const senderName = sender.length > 0 ? sender[0].real_name : '系统管理员'
    
    const [result] = await db.query(
      'INSERT INTO notifications (title, content, type, sender_id, sender_name, receiver_role) VALUES (?, ?, ?, ?, ?, ?)',
      [title, content, type, senderId, senderName, receiverRole]
    )
    
    res.json({
      code: 200,
      message: '发布成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 删除通知
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    await db.query('DELETE FROM notifications WHERE id = ?', [id])
    
    res.json({
      code: 200,
      message: '删除成功'
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 获取用户未读通知
router.get('/unread', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id
    const userRole = req.user.role
    
    const [notifications] = await db.query(`
      SELECT n.* FROM notifications n
      WHERE (n.receiver_role = ? OR n.receiver_role = 'all')
      AND n.id NOT IN (
        SELECT notification_id FROM notification_reads WHERE user_id = ?
      )
      ORDER BY n.created_at DESC
      LIMIT 10
    `, [userRole, userId])
    
    res.json({
      code: 200,
      data: notifications.map(n => ({
        id: n.id,
        title: n.title,
        content: n.content,
        type: n.type,
        senderName: n.sender_name,
        createdAt: n.created_at
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 标记通知为已读
router.post('/read/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const userId = req.user.id
    
    // 检查是否已读
    const [existing] = await db.query(
      'SELECT id FROM notification_reads WHERE notification_id = ? AND user_id = ?',
      [id, userId]
    )
    
    if (existing.length === 0) {
      await db.query(
        'INSERT INTO notification_reads (notification_id, user_id) VALUES (?, ?)',
        [id, userId]
      )
    }
    
    res.json({
      code: 200,
      message: '已标记为已读'
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

export default router
