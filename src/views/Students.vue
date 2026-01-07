<template>
  <div class="students-page">
    <el-card class="card-shadow">
      <!-- 搜索栏 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="学号">
          <el-input v-model="searchForm.studentNo" placeholder="请输入学号" clearable />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="searchForm.realName" placeholder="请输入姓名" clearable />
        </el-form-item>
        <el-form-item label="年级">
          <el-input v-model="searchForm.grade" placeholder="请输入年级" clearable />
        </el-form-item>
        <el-form-item label="班级">
          <el-input v-model="searchForm.class" placeholder="请输入班级" clearable />
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
      
      <!-- 操作按钮 -->
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          添加学生
        </el-button>
        <el-button type="warning" @click="handleExport">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
      
      <!-- 表格 -->
      <el-table
        :data="tableData"
        style="width: 100%"
        v-loading="loading"
        stripe
        border
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="gender" label="性别" width="80">
          <template #default="{ row }">
            <el-tag :type="row.gender === '男' ? 'primary' : 'danger'" size="small">
              {{ row.gender }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="birthDate" label="出生日期" width="120" />
        <el-table-column prop="grade" label="年级" width="100">
          <template #default="{ row }">
            {{ row.grade }}级
          </template>
        </el-table-column>
        <el-table-column prop="class" label="班级" width="150" />
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status ? 'success' : 'info'" size="small">
              {{ row.status ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleView(row)">
              <el-icon><View /></el-icon>
              查看
            </el-button>
            <el-button type="primary" size="small" link @click="handleEdit(row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        class="pagination"
      />
    </el-card>
    
    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="学号" prop="studentNo">
          <el-input v-model="formData.studentNo" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="formData.realName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="性别" prop="gender">
          <el-radio-group v-model="formData.gender">
            <el-radio label="男">男</el-radio>
            <el-radio label="女">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="出生日期" prop="birthDate">
          <el-date-picker
            v-model="formData.birthDate"
            type="date"
            placeholder="请选择出生日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-input v-model="formData.grade" placeholder="请输入年级，如：2024" style="width: 100%" />
        </el-form-item>
        <el-form-item label="班级" prop="class">
          <el-input v-model="formData.class" placeholder="请输入班级" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="formData.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="家庭地址" prop="address">
          <el-input
            v-model="formData.address"
            type="textarea"
            :rows="3"
            placeholder="请输入家庭地址"
          />
        </el-form-item>
        <el-form-item label="紧急联系人" prop="emergencyContact">
          <el-input v-model="formData.emergencyContact" placeholder="请输入紧急联系人电话" />
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
const dialogTitle = ref('添加学生')
const formRef = ref()

const searchForm = reactive({
  studentNo: '',
  realName: '',
  grade: '',
  class: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

const tableData = ref([])

const formData = reactive({
  id: '',
  studentNo: '',
  realName: '',
  gender: '男',
  birthDate: '',
  grade: '',
  class: '',
  phone: '',
  email: '',
  address: '',
  emergencyContact: ''
})

const rules = {
  studentNo: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }],
  grade: [{ required: true, message: '请选择年级', trigger: 'change' }],
  class: [{ required: true, message: '请输入班级', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/students', {
      params: {
        page: pagination.page,
        pageSize: pagination.pageSize,
        ...searchForm
      }
    })
    
    if (res.code === 200) {
      tableData.value = res.data.list
      pagination.total = res.data.total
    }
  } catch (error) {
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchData()
}

const handleReset = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

const handleAdd = () => {
  dialogTitle.value = '添加学生'
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑学生'
  Object.keys(formData).forEach(key => {
    if (key === 'birthDate' && row[key]) {
      // 确保日期格式为 YYYY-MM-DD
      if (typeof row[key] === 'string' && row[key].includes('T')) {
        formData[key] = row[key].split('T')[0]
      } else {
        formData[key] = row[key]
      }
    } else {
      formData[key] = row[key]
    }
  })
  dialogVisible.value = true
}

const handleView = (row) => {
  ElMessageBox.alert(
    `<div style="line-height: 2;">
      <p><strong>学号：</strong>${row.studentNo}</p>
      <p><strong>姓名：</strong>${row.realName}</p>
      <p><strong>性别：</strong>${row.gender}</p>
      <p><strong>出生日期：</strong>${row.birthDate || '未填写'}</p>
      <p><strong>年级：</strong>${row.grade}级</p>
      <p><strong>班级：</strong>${row.class}</p>
      <p><strong>联系电话：</strong>${row.phone}</p>
      <p><strong>邮箱：</strong>${row.email}</p>
      <p><strong>家庭地址：</strong>${row.address}</p>
      <p><strong>紧急联系人：</strong>${row.emergencyContact}</p>
    </div>`,
    '学生详情',
    {
      dangerouslyUseHTMLString: true,
      confirmButtonText: '关闭'
    }
  )
}

const handleDelete = async (row) => {
  try {
    // 第一次请求：检查关联数据
    const checkRes = await request.delete(`/students/${row.id}`)
    
    if (checkRes.code === 300) {
      // 有关联数据，需要二次确认
      ElMessageBox.confirm(
        checkRes.message + '\n\n删除学生会同时删除这些关联数据，此操作不可恢复！',
        '警告',
        {
          confirmButtonText: '确定删除',
          cancelButtonText: '取消',
          type: 'warning',
          dangerouslyUseHTMLString: true
        }
      ).then(async () => {
        // 用户确认后，强制删除
        try {
          const deleteRes = await request.delete(`/students/${row.id}?force=true`)
          if (deleteRes.code === 200) {
            ElMessage.success('删除成功')
            fetchData()
          } else {
            ElMessage.error(deleteRes.message || '删除失败')
          }
        } catch (error) {
          ElMessage.error('删除失败')
        }
      }).catch(() => {
        ElMessage.info('已取消删除')
      })
    } else if (checkRes.code === 200) {
      // 没有关联数据，直接删除成功
      ElMessage.success('删除成功')
      fetchData()
    } else {
      ElMessage.error(checkRes.message || '删除失败')
    }
  } catch (error) {
    ElMessage.error('删除失败')
  }
}

const handleSubmit = async () => {
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitLoading.value = true
    try {
      // 准备提交数据，确保日期格式正确
      const submitData = { ...formData }
      if (submitData.birthDate) {
        // 确保日期格式为 YYYY-MM-DD
        if (typeof submitData.birthDate === 'string' && submitData.birthDate.includes('T')) {
          submitData.birthDate = submitData.birthDate.split('T')[0]
        }
      }
      
      const url = formData.id ? `/students/${formData.id}` : '/students'
      const method = formData.id ? 'put' : 'post'
      const res = await request[method](url, submitData)
      
      if (res.code === 200) {
        ElMessage.success(formData.id ? '更新成功' : '添加成功')
        dialogVisible.value = false
        fetchData()
      }
    } catch (error) {
      ElMessage.error('操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
  Object.keys(formData).forEach(key => {
    if (key === 'gender') {
      formData[key] = '男'
    } else {
      formData[key] = ''
    }
  })
}

const handleImport = () => {
  ElMessage.info('批量导入功能提示:\n1. 准备Excel文件,包含列:学号、姓名、性别、年级、班级、联系电话、邮箱\n2. 或直接在MySQL中执行SQL批量插入\n3. 完整的Excel导入功能需要安装额外的库')
}

const handleExport = () => {
  if (tableData.value.length === 0) {
    ElMessage.warning('暂无数据可导出')
    return
  }
  
  // 生成CSV内容
  const headers = ['学号', '姓名', '性别', '年级', '班级', '联系电话', '邮箱', '家庭地址', '紧急联系人']
  const csvContent = [
    headers.join(','),
    ...tableData.value.map(row => [
      row.studentNo,
      row.realName,
      row.gender,
      row.grade,
      row.class,
      row.phone,
      row.email,
      row.address || '',
      row.emergencyContact || ''
    ].join(','))
  ].join('\n')
  
  // 添加BOM以支持中文
  const BOM = '\uFEFF'
  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  
  link.setAttribute('href', url)
  link.setAttribute('download', `学生信息_${new Date().getTime()}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
  ElMessage.success('导出成功')
}

const handleSizeChange = () => {
  fetchData()
}

const handleCurrentChange = () => {
  fetchData()
}
</script>

<style scoped>
.students-page {
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
