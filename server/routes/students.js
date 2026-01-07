import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取学生列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { page = 1, pageSize = 10, studentNo, realName, grade, class: className } = req.query
    const offset = (page - 1) * pageSize
    
    let sql = 'SELECT * FROM students WHERE 1=1'
    const params = []
    
    if (studentNo) {
      sql += ' AND student_no LIKE ?'
      params.push(`%${studentNo}%`)
    }
    if (realName) {
      sql += ' AND real_name LIKE ?'
      params.push(`%${realName}%`)
    }
    if (grade) {
      sql += ' AND grade = ?'
      params.push(grade)
    }
    if (className) {
      sql += ' AND class LIKE ?'
      params.push(`%${className}%`)
    }
    
    // 获取总数
    const [countResult] = await db.query(sql.replace('*', 'COUNT(*) as total'), params)
    const total = countResult[0].total
    
    // 获取列表
    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?'
    params.push(parseInt(pageSize), parseInt(offset))
    
    const [list] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: {
        list: list.map(item => ({
          id: item.id,
          studentNo: item.student_no,
          realName: item.real_name,
          gender: item.gender,
          birthDate: item.birth_date,
          grade: item.grade,
          class: item.class,
          phone: item.phone,
          email: item.email,
          address: item.address,
          emergencyContact: item.emergency_contact,
          status: item.status === 1
        })),
        total,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 添加学生
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { studentNo, realName, gender, birthDate, grade, class: className, phone, email, address, emergencyContact } = req.body
    
    // 数据验证
    if (!studentNo || !realName || !grade || !className) {
      return res.json({ code: 400, message: '学号、姓名、年级、班级为必填项' })
    }
    
    // 验证手机号格式
    if (phone && !/^1[3-9]\d{9}$/.test(phone)) {
      return res.json({ code: 400, message: '手机号格式不正确' })
    }
    
    // 验证邮箱格式
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.json({ code: 400, message: '邮箱格式不正确' })
    }
    
    // 检查学号是否已存在
    const [existingStudent] = await db.query('SELECT id FROM students WHERE student_no = ?', [studentNo])
    if (existingStudent.length > 0) {
      return res.json({ code: 400, message: '学号已存在' })
    }
    
    // 检查邮箱是否已存在
    if (email) {
      const [existingEmail] = await db.query('SELECT id FROM students WHERE email = ?', [email])
      if (existingEmail.length > 0) {
        return res.json({ code: 400, message: '邮箱已被使用' })
      }
    }
    
    // 添加学生
    const [result] = await db.query(
      'INSERT INTO students (student_no, real_name, gender, birth_date, grade, class, phone, email, address, emergency_contact) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [studentNo, realName, gender, birthDate, grade, className, phone, email, address, emergencyContact]
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

// 更新学生
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { studentNo, realName, gender, birthDate, grade, class: className, phone, email, address, emergencyContact } = req.body
    
    // 数据验证
    if (!studentNo || !realName || !grade || !className) {
      return res.json({ code: 400, message: '学号、姓名、年级、班级为必填项' })
    }
    
    // 验证手机号格式
    if (phone && !/^1[3-9]\d{9}$/.test(phone)) {
      return res.json({ code: 400, message: '手机号格式不正确' })
    }
    
    // 验证邮箱格式
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.json({ code: 400, message: '邮箱格式不正确' })
    }
    
    // 检查学生是否存在
    const [students] = await db.query('SELECT id FROM students WHERE id = ?', [id])
    if (students.length === 0) {
      return res.json({ code: 404, message: '学生不存在' })
    }
    
    // 更新学生信息
    await db.query(
      'UPDATE students SET student_no = ?, real_name = ?, gender = ?, birth_date = ?, grade = ?, class = ?, phone = ?, email = ?, address = ?, emergency_contact = ? WHERE id = ?',
      [studentNo, realName, gender, birthDate, grade, className, phone, email, address, emergencyContact, id]
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

// 删除学生
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { force } = req.query // 是否强制删除
    
    // 检查学生是否存在
    const [students] = await db.query('SELECT student_no, real_name FROM students WHERE id = ?', [id])
    if (students.length === 0) {
      return res.json({ code: 404, message: '学生不存在' })
    }
    
    // 如果不是强制删除，检查关联数据
    if (!force) {
      const [courseCount] = await db.query('SELECT COUNT(*) as count FROM student_courses WHERE student_id = ?', [id])
      const [scoreCount] = await db.query('SELECT COUNT(*) as count FROM scores WHERE student_id = ?', [id])
      const [attendanceCount] = await db.query('SELECT COUNT(*) as count FROM attendance WHERE student_id = ?', [id])
      
      const totalRelated = courseCount[0].count + scoreCount[0].count + attendanceCount[0].count
      
      // 如果有关联数据，返回需要确认
      if (totalRelated > 0) {
        return res.json({
          code: 300, // 使用300表示需要确认
          message: `该学生有 ${courseCount[0].count} 条选课记录、${scoreCount[0].count} 条成绩记录、${attendanceCount[0].count} 条考勤记录，确定要删除吗？`,
          data: {
            courses: courseCount[0].count,
            scores: scoreCount[0].count,
            attendance: attendanceCount[0].count
          }
        })
      }
    }
    
    // 删除学生（外键会级联删除相关数据）
    await db.query('DELETE FROM students WHERE id = ?', [id])
    
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
