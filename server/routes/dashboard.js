import express from 'express'
import db from '../config/db.js'
import { authMiddleware } from '../middleware/auth.js'

const router = express.Router()

// 获取统计数据
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    // 学生总数
    const [studentCount] = await db.query('SELECT COUNT(*) as count FROM students')
    
    // 课程总数
    const [courseCount] = await db.query('SELECT COUNT(*) as count FROM courses WHERE status = 1')
    
    // 教师总数
    const [teacherCount] = await db.query('SELECT COUNT(*) as count FROM users WHERE role = "teacher" AND status = 1')
    
    // 出勤率
    const [attendanceStats] = await db.query(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN type = '正常' THEN 1 ELSE 0 END) as normal
      FROM attendance
      WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    `)
    
    const attendanceRate = attendanceStats[0].total > 0 
      ? ((attendanceStats[0].normal / attendanceStats[0].total) * 100).toFixed(1)
      : 0
    
    res.json({
      code: 200,
      data: {
        studentCount: studentCount[0].count,
        courseCount: courseCount[0].count,
        teacherCount: teacherCount[0].count,
        attendanceRate: `${attendanceRate}%`
      }
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 获取成绩分布统计
router.get('/score-distribution', authMiddleware, async (req, res) => {
  try {
    const { courseId } = req.query
    
    let sql = `
      SELECT 
        SUM(CASE WHEN total_score >= 90 THEN 1 ELSE 0 END) as excellent,
        SUM(CASE WHEN total_score >= 80 AND total_score < 90 THEN 1 ELSE 0 END) as good,
        SUM(CASE WHEN total_score >= 70 AND total_score < 80 THEN 1 ELSE 0 END) as medium,
        SUM(CASE WHEN total_score >= 60 AND total_score < 70 THEN 1 ELSE 0 END) as pass,
        SUM(CASE WHEN total_score < 60 THEN 1 ELSE 0 END) as fail
      FROM scores
      WHERE 1=1
    `
    const params = []
    
    if (courseId) {
      sql += ' AND course_id = ?'
      params.push(courseId)
    }
    
    const [distribution] = await db.query(sql, params)
    
    res.json({
      code: 200,
      data: distribution[0]
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

// 获取考勤统计(支持不同时间范围)
router.get('/attendance-stats', authMiddleware, async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 7
    
    // 根据天数决定分组方式
    let sql, groupBy
    if (days <= 7) {
      // 7天内按星期分组
      sql = `
        SELECT 
          DAYNAME(attendance_date) as day_name,
          DAYOFWEEK(attendance_date) as day_num,
          SUM(CASE WHEN type = '正常' THEN 1 ELSE 0 END) as normal,
          SUM(CASE WHEN type = '迟到' THEN 1 ELSE 0 END) as late,
          SUM(CASE WHEN type = '早退' THEN 1 ELSE 0 END) as early,
          SUM(CASE WHEN type = '旷课' THEN 1 ELSE 0 END) as absent,
          SUM(CASE WHEN type = '请假' THEN 1 ELSE 0 END) as leave_count
        FROM attendance
        WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
        GROUP BY day_name, day_num
        ORDER BY day_num
      `
    } else {
      // 14天或30天按日期分组
      sql = `
        SELECT 
          DATE_FORMAT(attendance_date, '%m-%d') as date_label,
          attendance_date,
          SUM(CASE WHEN type = '正常' THEN 1 ELSE 0 END) as normal,
          SUM(CASE WHEN type = '迟到' THEN 1 ELSE 0 END) as late,
          SUM(CASE WHEN type = '早退' THEN 1 ELSE 0 END) as early,
          SUM(CASE WHEN type = '旷课' THEN 1 ELSE 0 END) as absent,
          SUM(CASE WHEN type = '请假' THEN 1 ELSE 0 END) as leave_count
        FROM attendance
        WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
        GROUP BY attendance_date, date_label
        ORDER BY attendance_date
      `
    }
    
    const [stats] = await db.query(sql, [days])
    
    let result
    if (days <= 7) {
      // 转换为中文星期
      const dayMap = {
        'Monday': '周一',
        'Tuesday': '周二',
        'Wednesday': '周三',
        'Thursday': '周四',
        'Friday': '周五',
        'Saturday': '周六',
        'Sunday': '周日'
      }
      
      result = stats.map(item => ({
        day: dayMap[item.day_name] || item.day_name,
        normal: item.normal || 0,
        late: item.late || 0,
        early: item.early || 0,
        absent: item.absent || 0,
        leave: item.leave_count || 0
      }))
    } else {
      // 使用日期标签
      result = stats.map(item => ({
        day: item.date_label,
        normal: item.normal || 0,
        late: item.late || 0,
        early: item.early || 0,
        absent: item.absent || 0,
        leave: item.leave_count || 0
      }))
    }
    
    res.json({
      code: 200,
      data: result
    })
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    })
  }
})

export default router
