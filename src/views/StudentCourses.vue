<template>
  <div class="student-courses-page">
    <el-card class="card-shadow">
      <el-form :inline="true" class="search-form">
        <el-form-item label="学号">
          <el-input v-model="searchForm.studentNo" placeholder="请输入学号" clearable />
        </el-form-item>
        <el-form-item label="课程">
          <el-input v-model="searchForm.courseName" placeholder="请输入课程名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="handleReset">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          添加选课
        </el-button>
      </div>
      
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="studentName" label="姓名" width="100" />
        <el-table-column prop="grade" label="年级" width="100" />
        <el-table-column prop="class" label="班级" width="120" />
        <el-table-column prop="courseNo" label="课程编号" width="120" />
        <el-table-column prop="courseName" label="课程名称" width="150" />
        <el-table-column prop="credit" label="学分" width="80" />
        <el-table-column prop="teacherName" label="授课教师" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag type="success" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="选课时间" width="180" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" size="small" link @click="handleDelete(row)">
              <el-icon><Delete /></el-icon>
              退课
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 添加选课对话框 -->
    <el-dialog v-model="dialogVisible" title="添加选课" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="学生" prop="studentId">
          <el-select 
            v-model="formData.studentId" 
            placeholder="请选择学生" 
            style="width: 100%" 
            filterable
          >
            <el-option 
              v-for="student in studentList" 
              :key="student.id" 
              :label="`${student.studentNo} - ${student.realName} (${student.grade}级${student.class})`" 
              :value="student.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="课程" prop="courseId">
          <el-select 
            v-model="formData.courseId" 
            placeholder="请选择课程" 
            style="width: 100%" 
            filterable
          >
            <el-option 
              v-for="course in courseList" 
              :key="course.id" 
              :label="`${course.courseNo} - ${course.courseName} (${course.credit}学分)`" 
              :value="course.id" 
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">
          确定
        </el-button>
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
const formRef = ref()

const searchForm = reactive({
  studentNo: '',
  courseName: ''
})

const tableData = ref([])
const studentList = ref([])
const courseList = ref([])

const formData = reactive({
  studentId: '',
  courseId: ''
})

const rules = {
  studentId: [{ required: true, message: '请选择学生', trigger: 'change' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }]
}

onMounted(() => {
  fetchData()
  fetchStudents()
  fetchCourses()
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/student-courses', { params: searchForm })
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

const handleSearch = () => {
  fetchData()
}

const handleReset = () => {
  searchForm.studentNo = ''
  searchForm.courseName = ''
  fetchData()
}

const handleAdd = () => {
  formData.studentId = ''
  formData.courseId = ''
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要为 ${row.studentName} 退选 ${row.courseName} 吗？`, '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      const res = await request.delete(`/student-courses/${row.id}`)
      if (res.code === 200) {
        ElMessage.success('退课成功')
        fetchData()
      }
    } catch (error) {
      ElMessage.error('退课失败')
    }
  })
}

const handleSubmit = async () => {
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitLoading.value = true
    try {
      const res = await request.post('/student-courses', formData)
      
      if (res.code === 200) {
        ElMessage.success('选课成功')
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
.student-courses-page {
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
