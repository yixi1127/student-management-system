import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('../views/Layout.vue'),
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '数据看板', icon: 'DataAnalysis' }
      },
      {
        path: 'students',
        name: 'Students',
        component: () => import('../views/Students.vue'),
        meta: { title: '学生管理', icon: 'User' }
      },
      {
        path: 'courses',
        name: 'Courses',
        component: () => import('../views/Courses.vue'),
        meta: { title: '课程管理', icon: 'Reading' }
      },
      {
        path: 'student-courses',
        name: 'StudentCourses',
        component: () => import('../views/StudentCourses.vue'),
        meta: { title: '选课管理', icon: 'Tickets' }
      },
      {
        path: 'scores',
        name: 'Scores',
        component: () => import('../views/Scores.vue'),
        meta: { title: '成绩管理', icon: 'Document' }
      },
      {
        path: 'attendance',
        name: 'Attendance',
        component: () => import('../views/Attendance.vue'),
        meta: { title: '考勤管理', icon: 'Calendar' }
      },
      {
        path: 'notifications',
        name: 'Notifications',
        component: () => import('../views/Notifications.vue'),
        meta: { title: '通知管理', icon: 'Bell' }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('../views/Profile.vue'),
        meta: { title: '个人中心', icon: 'User' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  if (to.meta.requiresAuth && !userStore.token) {
    next('/login')
  } else if (to.path === '/login' && userStore.token) {
    next('/')
  } else {
    next()
  }
})

export default router
