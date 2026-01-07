import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取成绩列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { studentNo, courseName } = req.query
    
    let sql = `
      SELECT sc.*, s.grade, s.class
      FROM scores sc
      LEFT JOIN students s ON sc.student_id = s.id
      WHERE 1=1
    `
    const params = []
    
    if (studentNo) {
      sql += ' AND (sc.student_no LIKE ? OR sc.student_name LIKE ?)'
      params.push(`%${studentNo}%`, `%${studentNo}%`)
    }
    if (courseName) {
      sql += ' AND sc.course_name LIKE ?'
      params.push(`%${courseName}%`)
    }
    
    sql += ' ORDER BY sc.updated_at DESC LIMIT 100'
    
    const [scores] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: scores.map(s => ({
        id: s.id,
        studentId: s.student_id,
        studentNo: s.student_no,
        studentName: s.student_name,
        grade: s.grade,
        class: s.class,
        courseId: s.course_id,
        courseName: s.course_name,
        usualScore: s.usual_score,
        finalScore: s.final_score,
        totalScore: s.total_score,
        teacherId: s.teacher_id,
        teacherName: s.teacher_name,
        updateTime: s.updated_at
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 录入成绩
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { studentId, courseId, usualScore, finalScore } = req.body
    
    // 数据验证
    if (!studentId || !courseId) {
      return res.json({ code: 400, message: '学生和课程为必填项' })
    }
    
    // 验证成绩范围
    if (usualScore !== null && usualScore !== undefined && (usualScore < 0 || usualScore > 100)) {
      return res.json({ code: 400, message: '平时分必须在0-100之间' })
    }
    if (finalScore !== null && finalScore !== undefined && (finalScore < 0 || finalScore > 100)) {
      return res.json({ code: 400, message: '期末分必须在0-100之间' })
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
    
    // 计算总分
    const totalScore = (usualScore || 0) * 0.3 + (finalScore || 0) * 0.7
    
    // 检查是否已存在成绩
    const [existing] = await db.query(
      'SELECT id FROM scores WHERE student_id = ? AND course_id = ?',
      [studentId, courseId]
    )
    
    if (existing.length > 0) {
      return res.json({ code: 400, message: '该学生该课程的成绩已存在，请使用修改功能' })
    }
    
    const [result] = await db.query(
      `INSERT INTO scores (student_id, student_no, student_name, grade, class, course_id, course_name, 
       usual_score, final_score, total_score, teacher_id, teacher_name) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [studentId, students[0].student_no, students[0].real_name, students[0].grade, students[0].class,
       courseId, courses[0].course_name, usualScore, finalScore, totalScore, teacherId, teacherName]
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

// 更新成绩
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { usualScore, finalScore } = req.body
    
    // 验证成绩范围
    if (usualScore !== null && usualScore !== undefined && (usualScore < 0 || usualScore > 100)) {
      return res.json({ code: 400, message: '平时分必须在0-100之间' })
    }
    if (finalScore !== null && finalScore !== undefined && (finalScore < 0 || finalScore > 100)) {
      return res.json({ code: 400, message: '期末分必须在0-100之间' })
    }
    
    // 计算总分
    const totalScore = (usualScore || 0) * 0.3 + (finalScore || 0) * 0.7
    
    await db.query(
      'UPDATE scores SET usual_score = ?, final_score = ?, total_score = ? WHERE id = ?',
      [usualScore, finalScore, totalScore, id]
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

// 删除成绩
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    await db.query('DELETE FROM scores WHERE id = ?', [id])
    
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
