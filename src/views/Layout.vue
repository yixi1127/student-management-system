<template>
  <el-container class="layout-container">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '64px' : '220px'" class="sidebar">
      <div class="logo">
        <el-icon v-if="isCollapse" size="28"><School /></el-icon>
        <template v-else>
          <el-icon size="28"><School /></el-icon>
          <span>学生管理系统</span>
        </template>
      </div>
      
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        router
        class="sidebar-menu"
      >
        <el-menu-item
          v-for="item in menuList"
          :key="item.path"
          :index="item.path"
        >
          <el-icon><component :is="item.meta.icon" /></el-icon>
          <template #title>{{ item.meta.title }}</template>
        </el-menu-item>
      </el-menu>
    </el-aside>
    
    <!-- 主内容区 -->
    <el-container>
      <!-- 顶部导航 -->
      <el-header class="header">
        <div class="header-left">
          <el-icon class="collapse-icon" @click="toggleCollapse">
            <Expand v-if="isCollapse" />
            <Fold v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="currentRoute.meta.title">
              {{ currentRoute.meta.title }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        
        <div class="header-right">
          <el-popover
            placement="bottom"
            :width="400"
            trigger="click"
            @show="fetchUnreadNotifications"
          >
            <template #reference>
              <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="notification-badge">
                <el-icon size="20" style="cursor: pointer"><Bell /></el-icon>
              </el-badge>
            </template>
            <div class="notification-list">
              <div class="notification-header">
                <span style="font-weight: 600">未读通知</span>
                <el-button type="primary" link size="small" @click="markAllAsRead">全部已读</el-button>
              </div>
              <el-divider style="margin: 10px 0" />
              <div v-if="unreadNotifications.length === 0" class="empty-notification">
                <el-empty description="暂无未读通知" :image-size="80" />
              </div>
              <div v-else class="notification-items">
                <div 
                  v-for="item in unreadNotifications" 
                  :key="item.id" 
                  class="notification-item"
                  @click="handleNotificationClick(item)"
                >
                  <div class="notification-title">
                    <el-tag :type="item.type === '系统' ? 'danger' : 'primary'" size="small">
                      {{ item.type }}
                    </el-tag>
                    <span>{{ item.title }}</span>
                  </div>
                  <div class="notification-content">{{ item.content }}</div>
                  <div class="notification-time">{{ item.createdAt }}</div>
                </div>
              </div>
              <el-divider style="margin: 10px 0" />
              <div style="text-align: center">
                <el-button type="primary" link @click="goToNotifications">查看全部通知</el-button>
              </div>
            </div>
          </el-popover>
          
          <el-dropdown @command="handleCommand">
            <div class="user-info">
              <el-avatar 
                :size="36" 
                :src="userStore.userInfo.avatar || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'" 
              />
              <span class="username">{{ userStore.userInfo.realName || userStore.userInfo.email }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  个人中心
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      
      <!-- 内容区 -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import request from '../utils/request'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isCollapse = ref(false)
const currentRoute = computed(() => route)
const activeMenu = computed(() => route.path)

const unreadNotifications = ref([])
const unreadCount = computed(() => unreadNotifications.value.length)

// 根据用户角色过滤菜单
const menuList = computed(() => {
  const routes = router.options.routes.find(r => r.path === '/')?.children || []
  const userRole = userStore.userInfo.role
  
  return routes.filter(item => {
    if (!item.meta?.title) return false
    if (!item.meta?.roles) return true
    return item.meta.roles.includes(userRole)
  })
})

onMounted(() => {
  fetchUnreadNotifications()
  // 每30秒刷新一次未读通知
  setInterval(fetchUnreadNotifications, 30000)
})

const fetchUnreadNotifications = async () => {
  try {
    const res = await request.get('/notifications/unread')
    if (res.code === 200) {
      unreadNotifications.value = res.data
    }
  } catch (error) {
    console.error('获取未读通知失败', error)
  }
}

const handleNotificationClick = async (item) => {
  try {
    // 标记为已读
    await request.post(`/notifications/read/${item.id}`)
    // 显示通知内容
    ElMessageBox.alert(item.content, item.title, {
      confirmButtonText: '关闭'
    })
    // 刷新未读通知
    fetchUnreadNotifications()
  } catch (error) {
    console.error('标记已读失败', error)
  }
}

const markAllAsRead = async () => {
  try {
    for (const item of unreadNotifications.value) {
      await request.post(`/notifications/read/${item.id}`)
    }
    ElMessage.success('已全部标记为已读')
    fetchUnreadNotifications()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

const goToNotifications = () => {
  router.push('/notifications')
}

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleCommand = (command) => {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      userStore.logout()
      router.push('/login')
      ElMessage.success('已退出登录')
    }).catch(() => {})
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.sidebar {
  background: #001529;
  transition: width 0.3s;
  overflow-x: hidden;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: white;
  font-size: 18px;
  font-weight: 600;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar-menu {
  border-right: none;
  background: #001529;
}

.sidebar-menu :deep(.el-menu-item) {
  color: rgba(255, 255, 255, 0.65);
}

.sidebar-menu :deep(.el-menu-item:hover) {
  color: white;
  background: rgba(255, 255, 255, 0.1);
}

.sidebar-menu :deep(.el-menu-item.is-active) {
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.header {
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.collapse-icon {
  font-size: 20px;
  cursor: pointer;
  transition: color 0.3s;
}

.collapse-icon:hover {
  color: #667eea;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

.notification-badge {
  cursor: pointer;
}

.notification-list {
  max-height: 500px;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 5px;
}

.notification-items {
  max-height: 400px;
  overflow-y: auto;
}

.notification-item {
  padding: 12px;
  cursor: pointer;
  border-radius: 8px;
  margin-bottom: 8px;
  transition: background-color 0.3s;
}

.notification-item:hover {
  background-color: #f5f7fa;
}

.notification-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  margin-bottom: 8px;
}

.notification-content {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.notification-time {
  font-size: 12px;
  color: #909399;
}

.empty-notification {
  padding: 20px 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.username {
  font-size: 14px;
  color: #333;
}

.main-content {
  background: #f0f2f5;
  padding: 24px;
  overflow-y: auto;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s, transform 0.3s;
}

.fade-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
