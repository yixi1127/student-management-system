<template>
  <div class="scores-page">
    <el-card class="card-shadow">
      <el-form :inline="true" class="search-form" :model="searchForm">
        <el-form-item label="学生">
          <el-input v-model="searchForm.studentNo" placeholder="请输入学号或姓名" clearable />
        </el-form-item>
        <el-form-item label="课程">
          <el-input v-model="searchForm.courseName" placeholder="请输入课程名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon>搜索</el-button>
          <el-button @click="handleReset"><el-icon><Refresh /></el-icon>重置</el-button>
        </el-form-item>
      </el-form>
      
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon>录入成绩</el-button>
      </div>
      
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="studentName" label="姓名" width="100" />
        <el-table-column prop="grade" label="年级" width="100" />
        <el-table-column prop="class" label="班级" width="120" />
        <el-table-column prop="courseName" label="课程" width="150" />
        <el-table-column prop="usualScore" label="平时分" width="100" />
        <el-table-column prop="finalScore" label="期末分" width="100" />
        <el-table-column prop="totalScore" label="总分" width="100">
          <template #default="{ row }">
            <el-tag :type="row.totalScore >= 90 ? 'success' : row.totalScore >= 60 ? '' : 'danger'">
              {{ row.totalScore }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="teacherName" label="录入教师" width="100" />
        <el-table-column prop="updateTime" label="更新时间" width="180" />
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
        <el-form-item label="平时分" prop="usualScore">
          <el-input-number v-model="formData.usualScore" :min="0" :max="100" :precision="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="期末分" prop="finalScore">
          <el-input-number v-model="formData.finalScore" :min="0" :max="100" :precision="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="总分">
          <el-tag type="info">{{ totalScore }}</el-tag>
          <span style="margin-left: 10px; color: #999; font-size: 12px;">（平时分30% + 期末分70%）</span>
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
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../utils/request'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('录入成绩')
const formRef = ref()

const searchForm = reactive({
  studentNo: '',
  courseName: ''
})

const tableData = ref([])
const studentList = ref([])
const courseList = ref([])

const formData = reactive({
  id: '',
  studentId: '',
  courseId: '',
  usualScore: 0,
  finalScore: 0
})

const rules = {
  studentId: [{ required: true, message: '请选择学生', trigger: 'change' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  usualScore: [{ required: true, message: '请输入平时分', trigger: 'blur' }],
  finalScore: [{ required: true, message: '请输入期末分', trigger: 'blur' }]
}

const totalScore = computed(() => {
  return (formData.usualScore * 0.3 + formData.finalScore * 0.7).toFixed(1)
})

onMounted(() => {
  fetchData()
  fetchStudents()
  fetchCourses()
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/scores', { params: searchForm })
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
  dialogTitle.value = '录入成绩'
  Object.keys(formData).forEach(key => {
    formData[key] = ['usualScore', 'finalScore'].includes(key) ? 0 : ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑成绩'
  formData.id = row.id
  formData.studentId = row.studentId
  formData.courseId = row.courseId
  formData.usualScore = row.usualScore
  formData.finalScore = row.finalScore
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该成绩吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      const res = await request.delete(`/scores/${row.id}`)
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
      const url = formData.id ? `/scores/${formData.id}` : '/scores'
      const method = formData.id ? 'put' : 'post'
      const res = await request[method](url, formData)
      
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
.scores-page {
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
