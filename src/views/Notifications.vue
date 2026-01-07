<template>
  <div class="notifications-page">
    <el-card class="card-shadow">
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          发布通知
        </el-button>
      </div>
      
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="title" label="标题" min-width="200">
          <template #default="{ row }">
            <el-link type="primary" @click="handleView(row)" :underline="false">
              {{ row.title }}
            </el-link>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === '系统' ? 'danger' : 'primary'" size="small">
              {{ row.type }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="senderName" label="发布人" width="120" />
        <el-table-column prop="receiverRole" label="接收对象" width="120">
          <template #default="{ row }">
            {{ getRoleText(row.receiverRole) }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="发布时间" width="180" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleView(row)">查看</el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="dialogVisible" title="发布通知" width="600px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="通知标题" prop="title">
          <el-input v-model="formData.title" placeholder="请输入通知标题" />
        </el-form-item>
        <el-form-item label="通知类型" prop="type">
          <el-radio-group v-model="formData.type">
            <el-radio label="系统">系统通知</el-radio>
            <el-radio label="课程">课程通知</el-radio>
            <el-radio label="考试">考试通知</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="接收对象" prop="receiverRole">
          <el-select v-model="formData.receiverRole" placeholder="请选择" style="width: 100%">
            <el-option label="全部" value="all" />
            <el-option label="学生" value="student" />
            <el-option label="教师" value="teacher" />
            <el-option label="管理员" value="admin" />
          </el-select>
        </el-form-item>
        <el-form-item label="通知内容" prop="content">
          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="6"
            placeholder="请输入通知内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">发布</el-button>
      </template>
    </el-dialog>
    
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
            <span class="value">{{ viewData.createdAt }}</span>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../utils/request'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const viewDialogVisible = ref(false)
const formRef = ref()

const tableData = ref([])

const formData = reactive({
  title: '',
  type: '系统',
  receiverRole: 'all',
  content: ''
})

const viewData = reactive({
  title: '',
  type: '',
  senderName: '',
  receiverRole: '',
  createdAt: '',
  content: ''
})

const rules = {
  title: [{ required: true, message: '请输入通知标题', trigger: 'blur' }],
  type: [{ required: true, message: '请选择通知类型', trigger: 'change' }],
  receiverRole: [{ required: true, message: '请选择接收对象', trigger: 'change' }],
  content: [{ required: true, message: '请输入通知内容', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/notifications')
    if (res.code === 200) {
      tableData.value = res.data
    }
  } catch (error) {
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
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

const handleAdd = () => {
  formData.title = ''
  formData.type = '系统'
  formData.receiverRole = 'all'
  formData.content = ''
  dialogVisible.value = true
}

const handleView = (row) => {
  viewData.title = row.title
  viewData.type = row.type
  viewData.senderName = row.senderName
  viewData.receiverRole = row.receiverRole
  viewData.createdAt = row.createdAt
  viewData.content = row.content
  viewDialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该通知吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      const res = await request.delete(`/notifications/${row.id}`)
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
      const res = await request.post('/notifications', formData)
      
      if (res.code === 200) {
        ElMessage.success('发布成功')
        dialogVisible.value = false
        fetchData()
      } else {
        ElMessage.error(res.message)
      }
    } catch (error) {
      ElMessage.error('发布失败')
    } finally {
      submitLoading.value = false
    }
  })
}
</script>

<style scoped>
.notifications-page {
  padding: 0;
}
.toolbar {
  margin-bottom: 20px;
}
.el-card {
  border-radius: 12px;
  border: none;
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
