# 快速开始指南

## 5分钟快速体验

### 1. 安装依赖

```bash
cd student-management-system
npm install
```

### 2. 配置 Supabase

#### 方式一：使用 Supabase 云服务（推荐）

1. 访问 [Supabase](https://supabase.com) 并注册账号
2. 创建新项目
3. 在项目设置中获取：
   - Project URL
   - anon public key

4. 复制 `.env.example` 为 `.env`：
```bash
cp .env.example .env
```

5. 编辑 `.env` 文件，填入你的配置：
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

6. 在 Supabase SQL Editor 中执行 `database.sql` 文件创建表结构

#### 方式二：使用模拟数据（快速体验）

如果暂时不想配置 Supabase，项目已经内置了模拟数据，可以直接运行查看界面效果。

### 3. 启动开发服务器

```bash
npm run dev
```

浏览器会自动打开 `http://localhost:3000`

### 4. 登录系统

#### 使用 Supabase 认证

首次使用需要注册账号：
1. 点击"立即注册"
2. 填写邮箱和密码
3. 注册成功后登录

#### 使用模拟数据

如果使用模拟数据模式，可以使用任意邮箱和密码（至少6位）登录。

### 5. 探索功能

登录后可以体验以下功能：

- **数据看板**：查看统计数据和图表
- **学生管理**：添加、编辑、删除学生信息
- **课程管理**：管理课程信息
- **成绩管理**：录入和查询成绩
- **考勤管理**：考勤记录管理
- **通知管理**：发布和查看通知
- **个人中心**：修改个人信息

## 常见问题

### Q: 启动失败，提示端口被占用

A: 修改 `vite.config.js` 中的端口号：
```js
server: {
  port: 3001, // 改为其他端口
  // ...
}
```

### Q: 登录失败

A: 检查以下几点：
1. `.env` 文件配置是否正确
2. Supabase 项目是否正常运行
3. 数据库表是否已创建
4. 浏览器控制台是否有错误信息

### Q: 页面显示异常

A: 尝试以下步骤：
1. 清除浏览器缓存
2. 重启开发服务器
3. 检查浏览器控制台错误信息

### Q: 如何修改默认角色

A: 在注册时，用户默认角色为 `student`。如需修改：
1. 在 Supabase Dashboard 中找到 `users` 表
2. 修改对应用户的 `role` 字段
3. 可选值：`super_admin`, `admin`, `teacher`, `student`

## 下一步

- 阅读 [README.md](./README.md) 了解完整功能
- 阅读 [DEPLOYMENT.md](./DEPLOYMENT.md) 了解部署流程
- 查看 [需求文档](../need/need.md) 了解系统设计

## 开发建议

### 推荐的开发工具

- **IDE**: VS Code
- **浏览器**: Chrome（推荐安装 Vue DevTools）
- **API 测试**: Postman 或 Insomnia

### VS Code 推荐插件

- Vue Language Features (Volar)
- ESLint
- Prettier
- Auto Rename Tag
- Path Intellisense

### 开发技巧

1. **热重载**：修改代码后自动刷新，无需手动刷新浏览器
2. **Vue DevTools**：安装后可以在浏览器中调试 Vue 组件
3. **控制台调试**：使用 `console.log()` 或浏览器断点调试
4. **Supabase Dashboard**：实时查看数据库数据变化

## 项目结构说明

```
student-management-system/
├── src/
│   ├── assets/          # 静态资源（图片、字体等）
│   ├── components/      # 可复用组件
│   ├── router/          # 路由配置
│   │   └── index.js     # 路由定义和守卫
│   ├── stores/          # Pinia 状态管理
│   │   └── user.js      # 用户状态
│   ├── utils/           # 工具函数
│   │   ├── supabase.js  # Supabase 客户端
│   │   └── request.js   # Axios 请求封装
│   ├── views/           # 页面组件
│   │   ├── Login.vue    # 登录页
│   │   ├── Layout.vue   # 主布局
│   │   ├── Dashboard.vue    # 数据看板
│   │   ├── Students.vue     # 学生管理
│   │   ├── Courses.vue      # 课程管理
│   │   ├── Scores.vue       # 成绩管理
│   │   ├── Attendance.vue   # 考勤管理
│   │   ├── Notifications.vue # 通知管理
│   │   └── Profile.vue      # 个人中心
│   ├── App.vue          # 根组件
│   ├── main.js          # 入口文件
│   └── style.css        # 全局样式
├── public/              # 公共资源
├── .env                 # 环境变量（需自行创建）
├── .env.example         # 环境变量示例
├── database.sql         # 数据库初始化脚本
├── vite.config.js       # Vite 配置
└── package.json         # 项目配置
```

## 自定义配置

### 修改主题色

编辑 `src/style.css`：
```css
/* 修改渐变色 */
background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
```

### 修改系统名称

1. 修改 `index.html` 中的 `<title>`
2. 修改 `src/views/Layout.vue` 中的 logo 文字
3. 修改 `src/views/Login.vue` 中的标题

### 添加新页面

1. 在 `src/views/` 创建新的 Vue 组件
2. 在 `src/router/index.js` 添加路由配置
3. 在 `src/views/Layout.vue` 的菜单中添加入口（如需要）

## 获取帮助

- 查看项目文档
- 查看 [Vue 3 文档](https://cn.vuejs.org/)
- 查看 [Element Plus 文档](https://element-plus.org/zh-CN/)
- 查看 [Supabase 文档](https://supabase.com/docs)
