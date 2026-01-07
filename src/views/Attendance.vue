<template>
  <div class="attendance-page">
    <el-card class="card-shadow">
      <el-form :inline="true" class="search-form">
        <el-form-item label="日期">
          <el-date-picker 
            v-model="dateRange" 
            type="daterange" 
            placeholder="选择日期范围"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="课程">
          <el-select v-model="searchCourseId" placeholder="请选择课程" clearable style="width: 200px">
            <el-option 
              v-for="course in courseList" 
              :key="course.id" 
              :label="course.courseName" 
              :value="course.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon>搜索</el-button>
        </el-form-item>
      </el-form>
      
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon>考勤录入</el-button>
      </div>
      
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="studentName" label="姓名" width="100" />
        <el-table-column prop="grade" label="年级" width="100">
          <template #default="{ row }">
            {{ row.grade }}级
          </template>
        </el-table-column>
        <el-table-column prop="class" label="班级" width="150" />
        <el-table-column prop="courseName" label="课程" width="180" />
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="type" label="考勤类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTypeColor(row.type)" size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="原因" min-width="150" />
        <el-table-column prop="teacherName" label="录入教师" width="100" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 录入/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="学生" prop="studentId">
          <el-select v-model="formData.studentId" placeholder="请选择学生" style="width: 100%" filterable>
            <el-option 
              v-for="student in studentList" 
              :key="student.id" 
              :label="`${student.studentNo} - ${student.realName}`" 
              :value="student.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="课程" prop="courseId">
          <el-select v-model="formData.courseId" placeholder="请选择课程" style="width: 100%" filterable>
            <el-option 
              v-for="course in courseList" 
              :key="course.id" 
              :label="course.courseName" 
              :value="course.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="日期" prop="date">
          <el-date-picker 
            v-model="formData.date" 
            type="date" 
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="考勤类型" prop="type">
          <el-radio-group v-model="formData.type">
            <el-radio label="正常">正常</el-radio>
            <el-radio label="迟到">迟到</el-radio>
            <el-radio label="早退">早退</el-radio>
            <el-radio label="旷课">旷课</el-radio>
            <el-radio label="请假">请假</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="原因" v-if="formData.type !== '正常'">
          <el-input 
            v-model="formData.reason" 
            type="textarea" 
            :rows="3" 
            placeholder="请输入原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../utils/request'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('考勤录入')
const formRef = ref()

const dateRange = ref([])
const searchCourseId = ref('')
const tableData = ref([])
const studentList = ref([])
const courseList = ref([])

const formData = reactive({
  id: '',
  studentId: '',
  courseId: '',
  date: '',
  type: '正常',
  reason: ''
})

const rules = {
  studentId: [{ required: true, message: '请选择学生', trigger: 'change' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  date: [{ required: true, message: '请选择日期', trigger: 'change' }],
  type: [{ required: true, message: '请选择考勤类型', trigger: 'change' }]
}

onMounted(() => {
  fetchData()
  fetchStudents()
  fetchCourses()
})

const fetchData = async () => {
  loading.value = true
  try {
    const params = {}
    if (dateRange.value && dateRange.value.length === 2) {
      params.startDate = dateRange.value[0]
      params.endDate = dateRange.value[1]
    }
    if (searchCourseId.value) {
      params.courseId = searchCourseId.value
    }
    
    const res = await request.get('/attendance', { params })
    if (res.code === 200) {
      tableData.value = res.data
    }
  } catch (error) {
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

const fetchStudents = async () => {
  try {
    const res = await request.get('/students', { params: { pageSize: 1000 } })
    if (res.code === 200) {
      studentList.value = res.data.list
    }
  } catch (error) {
    console.error('获取学生列表失败')
  }
}

const fetchCourses = async () => {
  try {
    const res = await request.get('/courses')
    if (res.code === 200) {
      courseList.value = res.data
    }
  } catch (error) {
    console.error('获取课程列表失败')
  }
}

const getTypeColor = (type) => {
  const colorMap = {
    '正常': 'success',
    '迟到': 'warning',
    '早退': 'warning',
    '旷课': 'danger',
    '请假': 'info'
  }
  return colorMap[type] || ''
}

const handleSearch = () => {
  fetchData()
}

const handleAdd = () => {
  dialogTitle.value = '考勤录入'
  Object.keys(formData).forEach(key => {
    formData[key] = key === 'type' ? '正常' : ''
  })
  // 设置默认日期为今天
  const today = new Date()
  const year = today.getFullYear()
  const month = String(today.getMonth() + 1).padStart(2, '0')
  const day = String(today.getDate()).padStart(2, '0')
  formData.date = `${year}-${month}-${day}`
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑考勤'
  formData.id = row.id
  formData.studentId = row.studentId
  formData.courseId = row.courseId
  formData.date = row.date
  formData.type = row.type
  formData.reason = row.reason || ''
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该考勤记录吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      const res = await request.delete(`/attendance/${row.id}`)
      if (res.code === 200) {
        ElMessage.success('删除成功')
        fetchData()
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  })
}

const handleSubmit = async () => {
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitLoading.value = true
    try {
      // 转换日期格式为 YYYY-MM-DD
      const submitData = {
        ...formData,
        date: formData.date ? formData.date.split('T')[0] : formData.date
      }
      
      const url = formData.id ? `/attendance/${formData.id}` : '/attendance'
      const method = formData.id ? 'put' : 'post'
      const res = await request[method](url, submitData)
      
      if (res.code === 200) {
        ElMessage.success(formData.id ? '更新成功' : '录入成功')
        dialogVisible.value = false
        fetchData()
      } else {
        ElMessage.error(res.message)
      }
    } catch (error) {
      ElMessage.error('操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}
</script>

<style scoped>
.attendance-page {
  padding: 0;
}
.search-form {
  margin-bottom: 20px;
}
.toolbar {
  margin-bottom: 20px;
}
.el-card {
  border-radius: 12px;
  border: none;
}
</style>
