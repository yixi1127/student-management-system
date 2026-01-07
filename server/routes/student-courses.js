import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取选课列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { studentNo, courseName } = req.query
    
    let sql = `
      SELECT 
        sc.*,
        s.student_no,
        s.real_name as student_name,
        s.grade,
        s.class,
        c.course_no,
        c.course_name,
        c.credit,
        c.teacher_name
      FROM student_courses sc
      LEFT JOIN students s ON sc.student_id = s.id
      LEFT JOIN courses c ON sc.course_id = c.id
      WHERE 1=1
    `
    const params = []
    
    if (studentNo) {
      sql += ' AND s.student_no LIKE ?'
      params.push(`%${studentNo}%`)
    }
    if (courseName) {
      sql += ' AND c.course_name LIKE ?'
      params.push(`%${courseName}%`)
    }
    
    sql += ' ORDER BY sc.created_at DESC LIMIT 200'
    
    const [selections] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: selections.map(item => ({
        id: item.id,
        studentId: item.student_id,
        studentNo: item.student_no,
        studentName: item.student_name,
        grade: item.grade,
        class: item.class,
        courseId: item.course_id,
        courseNo: item.course_no,
        courseName: item.course_name,
        credit: item.credit,
        teacherName: item.teacher_name,
        status: item.status,
        createdAt: item.created_at
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 添加选课
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { studentId, courseId } = req.body
    
    // 检查是否已选课
    const [existing] = await db.query(
      'SELECT id FROM student_courses WHERE student_id = ? AND course_id = ?',
      [studentId, courseId]
    )
    
    if (existing.length > 0) {
      return res.json({ code: 400, message: '该学生已选择此课程' })
    }
    
    const [result] = await db.query(
      'INSERT INTO student_courses (student_id, course_id, status) VALUES (?, ?, ?)',
      [studentId, courseId, '已选']
    )
    
    res.json({
      code: 200,
      message: '选课成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 删除选课(退课)
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    await db.query('DELETE FROM student_courses WHERE id = ?', [id])
    
    res.json({
      code: 200,
      message: '退课成功'
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

export default router
