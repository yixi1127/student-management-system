import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    const message = error.response?.data?.message || error.message || '请求失败'
    ElMessage.error(message)
    
    if (error.response?.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      window.location.href = '/login'
    }
    
    return Promise.reject(error)
  }
)

export default request
