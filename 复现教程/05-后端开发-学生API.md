# 第五步：后端开发 - 学生管理API

## 1. 创建学生路由

创建 `routes/students.js`：

```javascript
import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取学生列表（带分页和搜索）
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
    const [countResult] = await db.query(
      sql.replace('*', 'COUNT(*) as total'), 
      params
    )
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
    res.status(500).json({ code: 500, message: error.message })
  }
})

// 添加学生
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { studentNo, realName, gender, birthDate, grade, class: className, 
            phone, email, address, emergencyContact } = req.body
    
    // 数据验证
    if (!studentNo || !realName || !grade || !className) {
      return res.json({ code: 400, message: '学号、姓名、年级、班级为必填项' })
    }
    
    // 检查学号是否已存在
    const [existing] = await db.query(
      'SELECT id FROM students WHERE student_no = ?', 
      [studentNo]
    )
    
    if (existing.length > 0) {
      return res.json({ code: 400, message: '学号已存在' })
    }
    
    // 添加学生
    const [result] = await db.query(
      `INSERT INTO students (student_no, real_name, gender, birth_date, grade, class, 
       phone, email, address, emergency_contact) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [studentNo, realName, gender, birthDate, grade, className, 
       phone, email, address, emergencyContact]
    )
    
    res.json({
      code: 200,
      message: '添加成功',
      data: { id: result.insertId }
    })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

// 更新学生
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { studentNo, realName, gender, birthDate, grade, class: className,
            phone, email, address, emergencyContact } = req.body
    
    await db.query(
      `UPDATE students SET student_no = ?, real_name = ?, gender = ?, birth_date = ?,
       grade = ?, class = ?, phone = ?, email = ?, address = ?, emergency_contact = ? 
       WHERE id = ?`,
      [studentNo, realName, gender, birthDate, grade, className,
       phone, email, address, emergencyContact, id]
    )
    
    res.json({ code: 200, message: '更新成功' })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

// 删除学生
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params
    const { force } = req.query
    
    if (!force) {
      // 检查关联数据
      const [courseCount] = await db.query(
        'SELECT COUNT(*) as count FROM student_courses WHERE student_id = ?', 
        [id]
      )
      const [scoreCount] = await db.query(
        'SELECT COUNT(*) as count FROM scores WHERE student_id = ?', 
        [id]
      )
      const [attendanceCount] = await db.query(
        'SELECT COUNT(*) as count FROM attendance WHERE student_id = ?', 
        [id]
      )
      
      const totalRelated = courseCount[0].count + scoreCount[0].count + attendanceCount[0].count
      
      if (totalRelated > 0) {
        return res.json({
          code: 300,
          message: `该学生有 ${courseCount[0].count} 条选课记录、${scoreCount[0].count} 条成绩记录、${attendanceCount[0].count} 条考勤记录，确定要删除吗？`,
          data: {
            courses: courseCount[0].count,
            scores: scoreCount[0].count,
            attendance: attendanceCount[0].count
          }
        })
      }
    }
    
    // 删除关联数据
    await db.query('DELETE FROM student_courses WHERE student_id = ?', [id])
    await db.query('DELETE FROM scores WHERE student_id = ?', [id])
    await db.query('DELETE FROM attendance WHERE student_id = ?', [id])
    
    // 删除学生
    await db.query('DELETE FROM students WHERE id = ?', [id])
    
    res.json({ code: 200, message: '删除成功' })
  } catch (error) {
    res.status(500).json({ code: 500, message: error.message })
  }
})

export default router
```

## 2. 注册路由

在 `index.js` 中添加：

```javascript
import studentRoutes from './routes/students.js'

app.use('/api/students', studentRoutes)
```

## 3. 测试API

重启服务器，测试以下接口：

### 获取学生列表
```bash
GET http://localhost:3001/api/students?page=1&pageSize=10
Authorization: Bearer <token>
```

### 添加学生
```bash
POST http://localhost:3001/api/students
Authorization: Bearer <token>
Content-Type: application/json

{
  "studentNo": "2024003",
  "realName": "王五",
  "gender": "男",
  "birthDate": "2004-11-25",
  "grade": "2024",
  "class": "计算机2班",
  "phone": "13800000003",
  "email": "wangwu@qq.com"
}
```

## 下一步

学生API完成后，可以用同样的方式实现其他模块的API（课程、成绩、考勤等）
继续阅读 `06-前端开发-项目初始化.md`
