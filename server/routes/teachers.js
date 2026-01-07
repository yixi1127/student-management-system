import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取教师列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [teachers] = await db.query(`
      SELECT id, real_name as realName, email, phone
      FROM users
      WHERE role = 'teacher' AND status = 1
      ORDER BY created_at DESC
    `)
    
    res.json({
      code: 200,
      data: teachers
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

export default router
