<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>学生管理系统</h1>
        <p>Student Management System</p>
      </div>
      
      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="login-form">
        <el-form-item prop="email">
          <el-input
            v-model="loginForm.email"
            placeholder="请输入邮箱"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        
        <el-form-item>
          <el-checkbox v-model="loginForm.remember">记住我</el-checkbox>
        </el-form-item>
        
        <el-button
          type="primary"
          size="large"
          class="login-btn"
          :loading="loading"
          @click="handleLogin"
        >
          登 录
        </el-button>
      </el-form>
      
      <div class="login-footer">
        <span>还没有账号？</span>
        <el-link type="primary" @click="showRegister = true">立即注册</el-link>
      </div>
    </div>
    
    <!-- 注册对话框 -->
    <el-dialog v-model="showRegister" title="用户注册" width="400px">
      <el-form :model="registerForm" :rules="registerRules" ref="registerFormRef" label-width="80px">
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="registerForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="registerForm.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="registerForm.confirmPassword" type="password" placeholder="请再次输入密码" show-password />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="registerForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="registerForm.phone" placeholder="请输入手机号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRegister = false">取消</el-button>
        <el-button type="primary" @click="handleRegister" :loading="registerLoading">注册</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '../utils/request'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()
const loginFormRef = ref()
const registerFormRef = ref()
const loading = ref(false)
const registerLoading = ref(false)
const showRegister = ref(false)

const loginForm = reactive({
  email: '',
  password: '',
  remember: false
})

const registerForm = reactive({
  email: '',
  password: '',
  confirmPassword: '',
  realName: '',
  phone: ''
})

const rules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const registerRules = {
  ...rules,
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    loading.value = true
    try {
      const res = await request.post('/auth/login', {
        email: loginForm.email,
        password: loginForm.password
      })
      
      if (res.code === 200) {
        userStore.setToken(res.data.token)
        userStore.setUserInfo(res.data.user)
        
        ElMessage.success('登录成功')
        router.push('/')
      } else {
        throw new Error(res.message || '登录失败')
      }
    } catch (error) {
      ElMessage.error(error.message || '登录失败')
    } finally {
      loading.value = false
    }
  })
}

const handleRegister = async () => {
  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    registerLoading.value = true
    try {
      const res = await request.post('/auth/register', {
        email: registerForm.email,
        password: registerForm.password,
        realName: registerForm.realName,
        phone: registerForm.phone
      })
      
      if (res.code === 200) {
        ElMessage.success('注册成功，请登录')
        showRegister.value = false
        registerForm.email = ''
        registerForm.password = ''
        registerForm.confirmPassword = ''
        registerForm.realName = ''
        registerForm.phone = ''
      } else {
        throw new Error(res.message || '注册失败')
      }
    } catch (error) {
      ElMessage.error(error.message || '注册失败')
    } finally {
      registerLoading.value = false
    }
  })
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-box {
  width: 100%;
  max-width: 420px;
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-header h1 {
  font-size: 28px;
  color: #333;
  margin-bottom: 8px;
  font-weight: 600;
}

.login-header p {
  font-size: 14px;
  color: #999;
}

.login-form {
  margin-top: 30px;
}

.login-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  margin-top: 10px;
}

.login-btn:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

.login-footer {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #666;
}

.login-footer span {
  margin-right: 8px;
}
</style>
