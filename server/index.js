import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import authRoutes from './routes/auth.js'
import studentRoutes from './routes/students.js'
import courseRoutes from './routes/courses.js'
import scoreRoutes from './routes/scores.js'
import attendanceRoutes from './routes/attendance.js'
import notificationRoutes from './routes/notifications.js'
import dashboardRoutes from './routes/dashboard.js'
import teacherRoutes from './routes/teachers.js'
import studentCourseRoutes from './routes/student-courses.js'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3001

// 中间件
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// 路由
app.use('/api/auth', authRoutes)
app.use('/api/students', studentRoutes)
app.use('/api/courses', courseRoutes)
app.use('/api/scores', scoreRoutes)
app.use('/api/attendance', attendanceRoutes)
app.use('/api/notifications', notificationRoutes)
app.use('/api/dashboard', dashboardRoutes)
app.use('/api/teachers', teacherRoutes)
app.use('/api/student-courses', studentCourseRoutes)

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: '服务运行正常' })
})

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({
    code: 500,
    message: err.message || '服务器内部错误'
  })
})

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    code: 404,
    message: '接口不存在'
  })
})

app.listen(PORT, () => {
  console.log(`🚀 服务器运行在 http://localhost:${PORT}`)
  console.log(`📊 API 文档: http://localhost:${PORT}/api`)
})
