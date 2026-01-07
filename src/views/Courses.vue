<template>
  <div class="courses-page">
    <el-card class="card-shadow">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="课程编号">
          <el-input v-model="searchForm.courseNo" placeholder="请输入课程编号" clearable />
        </el-form-item>
        <el-form-item label="课程名称">
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
          添加课程
        </el-button>
      </div>
      
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="courseNo" label="课程编号" width="120" />
        <el-table-column prop="courseName" label="课程名称" width="180" />
        <el-table-column prop="credit" label="学分" width="80" />
        <el-table-column prop="teacherName" label="授课教师" width="120" />
        <el-table-column prop="classTime" label="上课时间" width="150" />
        <el-table-column prop="classroom" label="上课地点" width="120" />
        <el-table-column prop="studentCount" label="选课人数" width="100" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status ? 'success' : 'info'" size="small">
              {{ row.status ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :page-sizes="[10, 20, 50]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next"
        class="pagination"
      />
    </el-card>
    
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="课程编号" prop="courseNo">
          <el-input v-model="formData.courseNo" placeholder="请输入课程编号" />
        </el-form-item>
        <el-form-item label="课程名称" prop="courseName">
          <el-input v-model="formData.courseName" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="学分" prop="credit">
          <el-input-number v-model="formData.credit" :min="0" :max="10" :step="0.5" />
        </el-form-item>
        <el-form-item label="授课教师" prop="teacherName">
          <el-input v-model="formData.teacherName" placeholder="请输入授课教师姓名" />
        </el-form-item>
        <el-form-item label="上课时间" prop="classTime">
          <el-input v-model="formData.classTime" placeholder="如：周一1-2节" />
        </el-form-item>
        <el-form-item label="上课地点" prop="classroom">
          <el-input v-model="formData.classroom" placeholder="请输入上课地点" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../utils/request'

const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('添加课程')
const formRef = ref()

const searchForm = reactive({
  courseNo: '',
  courseName: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

const tableData = ref([])

const formData = reactive({
  id: '',
  courseNo: '',
  courseName: '',
  credit: 0,
  teacherName: '',
  classTime: '',
  classroom: ''
})

const rules = {
  courseNo: [{ required: true, message: '请输入课程编号', trigger: 'blur' }],
  courseName: [{ required: true, message: '请输入课程名称', trigger: 'blur' }],
  credit: [{ required: true, message: '请输入学分', trigger: 'blur' }],
  teacherName: [{ required: true, message: '请输入授课教师', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

const fetchData = async () => {
  loading.value = true
  try {
    const params = {
      courseNo: searchForm.courseNo,
      courseName: searchForm.courseName
    }
    const res = await request.get('/courses', { params })
    if (res.code === 200) {
      tableData.value = res.data
    }
  } catch (error) {
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  fetchData()
}

const handleReset = () => {
  searchForm.courseNo = ''
  searchForm.courseName = ''
  fetchData()
}

const handleAdd = () => {
  dialogTitle.value = '添加课程'
  Object.keys(formData).forEach(key => {
    formData[key] = key === 'credit' ? 0 : ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑课程'
  Object.keys(formData).forEach(key => {
    formData[key] = row[key]
  })
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该课程吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      const res = await request.delete(`/courses/${row.id}`)
      if (res.code === 200) {
        ElMessage.success('删除成功')
        fetchData()
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  })
}

const handleSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const url = formData.id ? `/courses/${formData.id}` : '/courses'
        const method = formData.id ? 'put' : 'post'
        const res = await request[method](url, formData)
        
        if (res.code === 200) {
          ElMessage.success(formData.id ? '更新成功' : '添加成功')
          dialogVisible.value = false
          fetchData()
        }
      } catch (error) {
        ElMessage.error('操作失败')
      }
    }
  })
}
</script>

<style scoped>
.courses-page {
  padding: 0;
}
.search-form {
  margin-bottom: 20px;
}
.toolbar {
  margin-bottom: 20px;
}
.pagination {
  margin-top: 20px;
  justify-content: flex-end;
}
.el-card {
  border-radius: 12px;
  border: none;
}
</style>
