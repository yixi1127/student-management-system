import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取考勤列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { startDate, endDate, courseId } = req.query
    
    let sql = `
      SELECT a.*, s.grade, s.class
      FROM attendance a
      LEFT JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `
    const params = []
    
    if (startDate && endDate) {
      sql += ' AND a.attendance_date BETWEEN ? AND ?'
      params.push(startDate, endDate)
    }
    if (courseId) {
      sql += ' AND a.course_id = ?'
      params.push(courseId)
    }
    
    sql += ' ORDER BY a.attendance_date DESC, a.created_at DESC LIMIT 200'
    
    const [attendance] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: attendance.map(a => ({
        id: a.id,
        studentId: a.student_id,
        studentNo: a.student_no,
        studentName: a.student_name,
        grade: a.grade,
        class: a.class,
        courseId: a.course_id,
        courseName: a.course_name,
        date: a.attendance_date,
        type: a.type,
        reason: a.reason,
        teacherId: a.teacher_id,
        teacherName: a.teacher_name
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 录入考勤
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { studentId, courseId, date, type, reason } = req.body
    
    // 数据验证
    if (!studentId || !courseId || !date || !type) {
      return res.json({ code: 400, message: '学生、课程、日期、考勤类型为必填项' })
    }
    
    // 获取当前登录用户信息（从JWT token）
    const teacherId = req.user.id
    const teacherName = req.user.realName || req.user.email
    
    // 获取学生信息
    const [students] = await db.query(
      'SELECT student_no, real_name, grade, class FROM students WHERE id = ?',
      [studentId]
    )
    
    if (students.length === 0) {
      return res.json({ code: 400, message: '学生不存在' })
    }
    
    // 获取课程信息
    const [courses] = await db.query('SELECT course_name FROM courses WHERE id = ?', [courseId])
    if (courses.length === 0) {
      return res.json({ code: 400, message: '课程不存在' })
    }
    
    const [result] = await db.query(
      `INSERT INTO attendance (student_id, student_no, student_name, grade, class, course_id, course_name, 
       attendance_date, type, reason, teacher_id, teacher_name) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [studentId, students[0].student_no, students[0].real_name, students[0].grade, students[0].class,
       courseId, courses[0].course_name, date, type, reason, teacherId, teacherName]
    )
    
    res.json({
      code: 200,
      message: '录入成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 更新考勤
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { date, type, reason } = req.body
    
    await db.query(
      'UPDATE attendance SET attendance_date = ?, type = ?, reason = ? WHERE id = ?',
      [date, type, reason, id]
    )
    
    res.json({
      code: 200,
      message: '更新成功'
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 删除考勤
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    await db.query('DELETE FROM attendance WHERE id = ?', [id])
    
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

export default router
