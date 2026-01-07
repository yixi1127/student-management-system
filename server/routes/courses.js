import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取课程列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { courseNo, courseName } = req.query
    
    let sql = `
      SELECT c.*, 
        (SELECT COUNT(*) FROM student_courses WHERE course_id = c.id) as student_count
      FROM courses c
      WHERE 1=1
    `
    const params = []
    
    if (courseNo) {
      sql += ' AND c.course_no LIKE ?'
      params.push(`%${courseNo}%`)
    }
    if (courseName) {
      sql += ' AND c.course_name LIKE ?'
      params.push(`%${courseName}%`)
    }
    
    sql += ' ORDER BY c.created_at DESC'
    
    const [courses] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: courses.map(c => ({
        id: c.id,
        courseNo: c.course_no,
        courseName: c.course_name,
        credit: c.credit,
        teacherId: c.teacher_id,
        teacherName: c.teacher_name,
        classTime: c.class_time,
        classroom: c.classroom,
        studentCount: c.student_count,
        status: c.status === 1
      }))
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 添加课程
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { courseNo, courseName, credit, teacherName, classTime, classroom } = req.body
    
    // 检查课程编号是否已存在
    const [existing] = await db.query('SELECT id FROM courses WHERE course_no = ?', [courseNo])
    if (existing.length > 0) {
      return res.json({ code: 400, message: '课程编号已存在' })
    }
    
    const [result] = await db.query(
      'INSERT INTO courses (course_no, course_name, credit, teacher_name, class_time, classroom) VALUES (?, ?, ?, ?, ?, ?)',
      [courseNo, courseName, credit, teacherName, classTime, classroom]
    )
    
    res.json({
      code: 200,
      message: '添加成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 更新课程
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { courseNo, courseName, credit, teacherName, classTime, classroom } = req.body
    
    await db.query(
      'UPDATE courses SET course_no = ?, course_name = ?, credit = ?, teacher_name = ?, class_time = ?, classroom = ? WHERE id = ?',
      [courseNo, courseName, credit, teacherName, classTime, classroom, id]
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

// 删除课程
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    await db.query('DELETE FROM courses WHERE id = ?', [id])
    
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
