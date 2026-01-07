<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :lg="8" v-for="item in statsData" :key="item.title">
        <el-card class="stat-card card-shadow">
          <div class="stat-content">
            <div class="stat-info">
              <div class="stat-title">{{ item.title }}</div>
              <div class="stat-value">{{ item.value }}</div>
            </div>
            <div class="stat-icon" :style="{ background: item.color }">
              <el-icon :size="32"><component :is="item.icon" /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 图表区域 -->
    <el-row :gutter="20" class="charts-row">
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card card-shadow">
          <template #header>
            <div class="card-header">
              <span>成绩分布统计</span>
              <el-select 
                v-model="selectedCourse" 
                placeholder="全部课程" 
                size="small" 
                style="width: 180px"
                @change="initScoreChart"
              >
                <el-option label="全部课程" value="" />
                <el-option 
                  v-for="course in courseList" 
                  :key="course.id" 
                  :label="course.courseName" 
                  :value="course.id" 
                />
              </el-select>
            </div>
          </template>
          <div ref="scoreChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card card-shadow">
          <template #header>
            <div class="card-header">
              <span>考勤统计</span>
              <el-radio-group v-model="attendanceDays" size="small" @change="initAttendanceChart">
                <el-radio-button :label="7">最近7天</el-radio-button>
                <el-radio-button :label="14">最近14天</el-radio-button>
                <el-radio-button :label="30">最近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="attendanceChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" class="charts-row">
      <el-col :xs="24">
        <el-card class="chart-card card-shadow">
          <template #header>
            <span>最新通知</span>
          </template>
          <el-timeline>
            <el-timeline-item
              v-for="item in notifications"
              :key="item.id"
              :timestamp="item.time"
              placement="top"
            >
              <el-link type="primary" :underline="false" @click="handleViewNotification(item)">
                {{ item.title }}
              </el-link>
            </el-timeline-item>
          </el-timeline>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 查看通知详情对话框 -->
    <el-dialog v-model="viewDialogVisible" :title="viewData.title" width="700px" class="notification-view-dialog">
      <div class="notification-detail">
        <div class="detail-header">
          <div class="detail-item">
            <span class="label">通知类型：</span>
            <el-tag :type="getTypeColor(viewData.type)" size="small">{{ viewData.type }}</el-tag>
          </div>
          <div class="detail-item">
            <span class="label">发布人：</span>
            <span class="value">{{ viewData.senderName }}</span>
          </div>
          <div class="detail-item">
            <span class="label">接收对象：</span>
            <span class="value">{{ getRoleText(viewData.receiverRole) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">发布时间：</span>
            <span class="value">{{ viewData.time }}</span>
          </div>
        </div>
        <el-divider />
        <div class="detail-content">
          <div class="content-label">通知内容：</div>
          <div class="content-text">{{ viewData.content }}</div>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="viewDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import request from '../utils/request'

const viewDialogVisible = ref(false)
const viewData = reactive({
  title: '',
  type: '',
  senderName: '',
  receiverRole: '',
  time: '',
  content: ''
})

const statsData = ref([
  {
    title: '学生总数',
    value: '0',
    icon: 'User',
    color: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
  },
  {
    title: '课程总数',
    value: '0',
    icon: 'Reading',
    color: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
  },
  {
    title: '出勤率',
    value: '0%',
    icon: 'Calendar',
    color: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)'
  }
])

const notifications = ref([])

const scoreChartRef = ref()
const attendanceChartRef = ref()
const selectedCourse = ref('')
const attendanceDays = ref(7)
const courseList = ref([])

onMounted(() => {
  fetchStats()
  fetchCourses()
  fetchNotifications()
  nextTick(() => {
    initScoreChart()
    initAttendanceChart()
  })
})

// 获取最新通知
const fetchNotifications = async () => {
  try {
    const res = await request.get('/notifications')
    if (res.code === 200) {
      // 只显示最新的5条通知，保存完整信息
      notifications.value = res.data.slice(0, 5).map(item => ({
        id: item.id,
        title: item.title,
        time: item.createdAt,
        content: item.content,
        type: item.type,
        senderName: item.senderName,
        receiverRole: item.receiverRole
      }))
    }
  } catch (error) {
    console.error('获取通知失败', error)
  }
}

// 查看通知详情
const handleViewNotification = (item) => {
  viewData.title = item.title
  viewData.type = item.type
  viewData.senderName = item.senderName
  viewData.receiverRole = item.receiverRole
  viewData.time = item.time
  viewData.content = item.content
  viewDialogVisible.value = true
}

const getRoleText = (role) => {
  const roleMap = {
    'all': '全部',
    'student': '学生',
    'teacher': '教师',
    'admin': '管理员'
  }
  return roleMap[role] || role
}

const getTypeColor = (type) => {
  const colorMap = {
    '系统': 'danger',
    '课程': 'primary',
    '考试': 'warning'
  }
  return colorMap[type] || ''
}

// 获取课程列表
const fetchCourses = async () => {
  try {
    const res = await request.get('/courses')
    if (res.code === 200) {
      courseList.value = res.data
    }
  } catch (error) {
    console.error('获取课程列表失败', error)
  }
}

// 获取统计数据
const fetchStats = async () => {
  try {
    const res = await request.get('/dashboard/stats')
    if (res.code === 200) {
      statsData.value[0].value = res.data.studentCount.toString()
      statsData.value[1].value = res.data.courseCount.toString()
      statsData.value[2].value = res.data.attendanceRate
    }
  } catch (error) {
    console.error('获取统计数据失败', error)
  }
}

// 初始化成绩分布图表
const initScoreChart = async () => {
  try {
    const params = selectedCourse.value ? { courseId: selectedCourse.value } : {}
    const res = await request.get('/dashboard/score-distribution', { params })
    const data = res.code === 200 ? res.data : {
      excellent: 0, good: 0, medium: 0, pass: 0, fail: 0
    }
    
    const chart = echarts.init(scoreChartRef.value)
    const option = {
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        right: '10%',
        top: 'center'
      },
      series: [
        {
          name: '成绩分布',
          type: 'pie',
          radius: ['40%', '70%'],
          center: ['35%', '50%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 10,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: {
            show: false
          },
          emphasis: {
            label: {
              show: true,
              fontSize: 16,
              fontWeight: 'bold'
            }
          },
          labelLine: {
            show: false
          },
          data: [
            { value: data.excellent, name: '优秀(90-100)', itemStyle: { color: '#5470c6' } },
            { value: data.good, name: '良好(80-89)', itemStyle: { color: '#91cc75' } },
            { value: data.medium, name: '中等(70-79)', itemStyle: { color: '#fac858' } },
            { value: data.pass, name: '及格(60-69)', itemStyle: { color: '#ee6666' } },
            { value: data.fail, name: '不及格(<60)', itemStyle: { color: '#73c0de' } }
          ]
        }
      ]
    }
    chart.setOption(option)
    window.addEventListener('resize', () => chart.resize())
  } catch (error) {
    console.error('获取成绩分布失败', error)
  }
}

// 初始化考勤统计图表
const initAttendanceChart = async () => {
  try {
    const res = await request.get('/dashboard/attendance-stats', {
      params: { days: attendanceDays.value }
    })
    const data = res.code === 200 ? res.data : []
    
    const days = data.map(item => item.day)
    const normalData = data.map(item => item.normal)
    const lateData = data.map(item => item.late)
    const earlyData = data.map(item => item.early)
    const absentData = data.map(item => item.absent)
    const leaveData = data.map(item => item.leave)
    
    const chart = echarts.init(attendanceChartRef.value)
    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        orient: 'vertical',
        right: '5%',
        top: 'center',
        data: ['正常', '迟到', '早退', '旷课', '请假']
      },
      grid: {
        left: '3%',
        right: '15%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: days.length > 0 ? days : ['暂无数据'],
        axisLabel: {
          interval: 0,
          rotate: days.length > 10 ? 45 : 0
        }
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          name: '正常',
          type: 'bar',
          stack: 'total',
          data: normalData,
          itemStyle: { color: '#5470c6' }
        },
        {
          name: '迟到',
          type: 'bar',
          stack: 'total',
          data: lateData,
          itemStyle: { color: '#91cc75' }
        },
        {
          name: '早退',
          type: 'bar',
          stack: 'total',
          data: earlyData,
          itemStyle: { color: '#fac858' }
        },
        {
          name: '旷课',
          type: 'bar',
          stack: 'total',
          data: absentData,
          itemStyle: { color: '#ee6666' }
        },
        {
          name: '请假',
          type: 'bar',
          stack: 'total',
          data: leaveData,
          itemStyle: { color: '#73c0de' }
        }
      ]
    }
    chart.setOption(option)
    window.addEventListener('resize', () => chart.resize())
  } catch (error) {
    console.error('获取考勤统计失败', error)
  }
}
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 12px;
  border: none;
}

.stat-card :deep(.el-card__body) {
  padding: 20px;
}

.stat-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-info {
  flex: 1;
}

.stat-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.charts-row {
  margin-bottom: 20px;
}

.chart-card {
  border-radius: 12px;
  border: none;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.el-timeline {
  padding-left: 0;
}

.notification-detail {
  padding: 10px 0;
}

.detail-header {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 10px;
}

.detail-item {
  display: flex;
  align-items: center;
  padding: 8px 0;
}

.detail-item .label {
  font-weight: 600;
  color: #606266;
  margin-right: 8px;
  min-width: 80px;
}

.detail-item .value {
  color: #303133;
}

.detail-content {
  margin-top: 20px;
}

.content-label {
  font-weight: 600;
  color: #606266;
  margin-bottom: 12px;
  font-size: 15px;
}

.content-text {
  background: #f5f7fa;
  padding: 20px;
  border-radius: 8px;
  line-height: 1.8;
  color: #303133;
  white-space: pre-wrap;
  word-break: break-word;
  min-height: 100px;
  font-size: 14px;
}
</style>

<style>
.notification-view-dialog .el-dialog__body {
  padding: 20px 30px;
}
</style>
