# 学生管理系统

基于 Vue3 + Vite + Element Plus + Supabase 开发的现代化学生管理系统。

## 功能特性

- 🎨 现代化UI设计，响应式布局
- 👥 用户认证与权限管理
- 📚 学生信息管理（增删改查）
- 📖 课程管理
- 📊 成绩管理
- 📅 考勤管理
- 📢 通知系统
- 📈 数据统计看板

## 技术栈

- **前端框架**: Vue 3 + Vite
- **UI组件库**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router
- **HTTP客户端**: Axios
- **数据可视化**: ECharts
- **后端服务**: Supabase
- **部署**: 阿里云

## 快速开始

### 安装依赖

```bash
npm install
```

### 配置环境变量

复制 `.env.example` 为 `.env`，并填入你的 Supabase 配置：

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 预览生产构建

```bash
npm run preview
```

## 项目结构

```
student-management-system/
├── src/
│   ├── assets/          # 静态资源
│   ├── components/      # 公共组件
│   ├── router/          # 路由配置
│   ├── stores/          # 状态管理
│   ├── utils/           # 工具函数
│   ├── views/           # 页面组件
│   ├── App.vue          # 根组件
│   ├── main.js          # 入口文件
│   └── style.css        # 全局样式
├── public/              # 公共资源
├── .env                 # 环境变量
├── index.html           # HTML模板
├── package.json         # 项目配置
└── vite.config.js       # Vite配置
```

## 功能模块

### 1. 数据看板
- 统计卡片展示（学生总数、课程总数、教师总数、出勤率）
- 成绩分布饼图
- 考勤统计柱状图
- 学生人数趋势图
- 最新通知列表

### 2. 学生管理
- 学生信息的增删改查
- 高级搜索（学号、姓名、年级、班级）
- 批量导入/导出
- 学生详情查看

### 3. 课程管理
- 课程信息维护
- 授课教师分配
- 上课时间地点管理
- 选课人数统计

### 4. 成绩管理
- 成绩录入与修改
- 平时分、期末分、总分计算
- 成绩查询与统计
- 批量导入成绩

### 5. 考勤管理
- 考勤记录录入
- 考勤类型（正常、迟到、早退、旷课、请假）
- 考勤统计与分析
- 请假审批

### 6. 通知管理
- 系统通知发布
- 课程通知发布
- 通知接收对象设置
- 已读/未读状态

### 7. 个人中心
- 个人信息修改
- 头像上传
- 密码修改

## 权限角色

- **超级管理员**: 系统全权限
- **普通管理员**: 学生/教师信息管理、课程/成绩/考勤维护
- **教师**: 查看授课学生、录入成绩/考勤、发布课程通知
- **学生**: 查看个人信息、课程/成绩/考勤记录、接收通知

## Supabase 数据库配置

请参考需求文档中的数据库设计部分，创建以下表：

- users（用户表）
- students（学生表）
- courses（课程表）
- student_courses（学生选课表）
- scores（成绩表）
- attendance（考勤表）
- notifications（通知表）

## 部署说明

### 阿里云部署

1. 构建项目：`npm run build`
2. 将 `dist` 目录上传至阿里云 OSS
3. 配置 CDN 加速
4. 配置域名和 HTTPS 证书

### Supabase 部署

1. 在阿里云 ECS 上部署 Supabase 开源版
2. 配置数据库和 RLS 策略
3. 设置环境变量

## 开发规范

- 使用 ESLint 进行代码检查
- 遵循 Vue 3 Composition API 规范
- 组件命名采用 PascalCase
- 文件命名采用 kebab-case

## 许可证

MIT License

## 联系方式

如有问题，请联系开发团队。
