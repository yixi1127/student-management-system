<template>
  <div class="profile-page">
    <el-row :gutter="20">
      <el-col :xs="24" :lg="8">
        <el-card class="card-shadow profile-card">
          <div class="profile-header">
            <el-avatar 
              :size="100" 
              :src="formData.avatar || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" 
            />
            <h3>{{ userInfo.email }}</h3>
            <el-tag type="primary">{{ getRoleName(userInfo.role) }}</el-tag>
          </div>
          <el-divider />
          <div class="profile-info">
            <div class="info-item">
              <span class="label">邮箱：</span>
              <span class="value">{{ userInfo.email }}</span>
            </div>
            <div class="info-item">
              <span class="label">角色：</span>
              <span class="value">{{ getRoleName(userInfo.role) }}</span>
            </div>
            <div class="info-item">
              <span class="label">注册时间：</span>
              <span class="value">{{ formatDate(userInfo.createdAt) }}</span>
            </div>
            <div class="info-item">
              <span class="label">真实姓名：</span>
              <span class="value">{{ userInfo.realName || '未设置' }}</span>
            </div>
            <div class="info-item">
              <span class="label">手机号：</span>
              <span class="value">{{ userInfo.phone || '未设置' }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :lg="16">
        <el-card class="card-shadow">
          <template #header>
            <span>个人信息</span>
          </template>
          <el-form :model="formData" label-width="100px">
            <el-form-item label="真实姓名">
              <el-input v-model="formData.realName" placeholder="请输入真实姓名" />
            </el-form-item>
            <el-form-item label="手机号">
              <el-input v-model="formData.phone" placeholder="请输入手机号" />
            </el-form-item>
            <el-form-item label="邮箱">
              <el-input v-model="formData.email" disabled />
            </el-form-item>
            <el-form-item label="头像">
              <div class="avatar-section">
                <el-avatar 
                  :size="80" 
                  :src="formData.avatar || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" 
                />
                <div class="avatar-options">
                  <el-input 
                    v-model="formData.avatar" 
                    placeholder="请输入头像URL地址"
                    style="margin-bottom: 10px"
                    @input="handleAvatarChange"
                  />
                  <div class="avatar-tips">
                    <el-text type="info" size="small">
                      提示：可以使用图床上传图片后粘贴链接，或使用在线头像服务
                    </el-text>
                  </div>
                  <div class="avatar-services">
                    <el-link type="primary" href="https://imgbb.com/" target="_blank" size="small">ImgBB图床</el-link>
                    <el-link type="primary" href="https://sm.ms/" target="_blank" size="small">SM.MS图床</el-link>
                    <el-link type="primary" href="https://cn.gravatar.com/" target="_blank" size="small">Gravatar</el-link>
                  </div>
                </div>
              </div>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSave">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>
        
        <el-card class="card-shadow" style="margin-top: 20px">
          <template #header>
            <span>修改密码</span>
          </template>
          <el-form :model="passwordForm" label-width="100px">
            <el-form-item label="原密码">
              <el-input v-model="passwordForm.oldPassword" type="password" show-password />
            </el-form-item>
            <el-form-item label="新密码">
              <el-input v-model="passwordForm.newPassword" type="password" show-password />
            </el-form-item>
            <el-form-item label="确认密码">
              <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleChangePassword">修改密码</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import request from '../utils/request'

const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

const formData = reactive({
  realName: userInfo.value.realName || '',
  phone: userInfo.value.phone || '',
  email: userInfo.value.email,
  avatar: userInfo.value.avatar || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'
})

const formatDate = (dateStr) => {
  if (!dateStr) return '未知'
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const getRoleName = (role) => {
  const roleMap = {
    'super_admin': '超级管理员',
    'admin': '管理员',
    'teacher': '教师',
    'student': '学生'
  }
  return roleMap[role] || '未知'
}

const handleAvatarChange = () => {
  // 头像URL改变时，formData.avatar会自动更新，Vue的响应式会自动更新显示
}

const handleSave = async () => {
  try {
    const res = await request.put('/auth/profile', {
      userId: userInfo.value.id,
      realName: formData.realName,
      phone: formData.phone,
      avatar: formData.avatar
    })
    
    if (res.code === 200) {
      // 更新本地用户信息
      userStore.setUserInfo(res.data)
      ElMessage.success('保存成功')
    } else {
      throw new Error(res.message || '保存失败')
    }
  } catch (error) {
    ElMessage.error(error.message || '保存失败')
  }
}

const handleChangePassword = async () => {
  if (!passwordForm.oldPassword) {
    ElMessage.error('请输入原密码')
    return
  }
  if (!passwordForm.newPassword) {
    ElMessage.error('请输入新密码')
    return
  }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    ElMessage.error('两次输入的密码不一致')
    return
  }
  if (passwordForm.newPassword.length < 6) {
    ElMessage.error('新密码长度不能少于6位')
    return
  }
  
  try {
    const res = await request.put('/auth/password', {
      userId: userInfo.value.id,
      oldPassword: passwordForm.oldPassword,
      newPassword: passwordForm.newPassword
    })
    
    if (res.code === 200) {
      ElMessage.success('密码修改成功')
      // 清空表单
      passwordForm.oldPassword = ''
      passwordForm.newPassword = ''
      passwordForm.confirmPassword = ''
    } else {
      throw new Error(res.message || '密码修改失败')
    }
  } catch (error) {
    ElMessage.error(error.message || '密码修改失败')
  }
}
</script>

<style scoped>
.profile-page {
  padding: 0;
}

.profile-card {
  border-radius: 12px;
  border: none;
}

.profile-header {
  text-align: center;
  padding: 20px 0;
}

.profile-header h3 {
  margin: 16px 0 8px;
  font-size: 20px;
  color: #333;
}

.profile-info {
  padding: 10px 0;
}

.info-item {
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item .label {
  color: #666;
  width: 100px;
}

.info-item .value {
  flex: 1;
  color: #333;
}

.avatar-section {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

.avatar-options {
  flex: 1;
}

.avatar-tips {
  margin-bottom: 10px;
}

.avatar-services {
  display: flex;
  gap: 15px;
}

.el-card {
  border-radius: 12px;
  border: none;
}
</style>
