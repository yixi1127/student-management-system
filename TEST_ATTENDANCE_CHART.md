# 考勤统计图表时间范围功能测试

## 功能说明
考勤统计图表现在支持三种时间范围选择:
- **最近7天**: 按星期显示(周一到周日)
- **最近14天**: 按日期显示(月-日格式)
- **最近30天**: 按日期显示(月-日格式)

## 后端修改
文件: `server/routes/dashboard.js`

### API接口
- **路径**: `GET /api/dashboard/attendance-stats`
- **参数**: `days` (可选,默认7天)
  - `days=7`: 最近7天
  - `days=14`: 最近14天
  - `days=30`: 最近30天

### 实现逻辑
1. 接收`days`参数,默认为7天
2. 根据天数选择不同的SQL查询:
   - **7天内**: 按星期分组,显示中文星期(周一、周二等)
   - **14天或30天**: 按日期分组,显示月-日格式(如01-05)
3. 返回统计数据包含:
   - `day`: 日期标签(星期或日期)
   - `normal`: 正常出勤数
   - `late`: 迟到数
   - `early`: 早退数
   - `absent`: 旷课数
   - `leave`: 请假数

## 前端实现
文件: `src/views/Dashboard.vue`

### UI组件
在考勤统计卡片头部添加了单选按钮组:
```vue
<el-radio-group v-model="attendanceDays" size="small" @change="initAttendanceChart">
  <el-radio-button :label="7">最近7天</el-radio-button>
  <el-radio-button :label="14">最近14天</el-radio-button>
  <el-radio-button :label="30">最近30天</el-radio-button>
</el-radio-group>
```

### 图表配置
- 图例位置: 右侧垂直排列
- X轴标签: 
  - 7天显示星期,不旋转
  - 14/30天显示日期,旋转45度(如果超过10个数据点)
- 堆叠柱状图: 显示5种考勤类型

## 测试步骤

### 1. 重启后端服务器
确保后端代码修改生效:
```bash
cd student-management-system/server
node index.js
```

### 2. 启动前端开发服务器
```bash
cd student-management-system
npm run dev
```

### 3. 测试功能
1. 登录系统(使用测试账号: admin@example.com / 123456)
2. 进入Dashboard页面
3. 找到"考勤统计"图表
4. 点击不同的时间范围按钮:
   - 点击"最近7天": 应显示按星期的统计
   - 点击"最近14天": 应显示按日期的统计
   - 点击"最近30天": 应显示按日期的统计
5. 观察图表数据是否正确更新

### 4. 验证数据
打开浏览器开发者工具(F12),查看Network标签:
- 切换时间范围时应看到API请求: `/api/dashboard/attendance-stats?days=7` (或14、30)
- 检查返回的数据格式是否正确

## 预期结果
- 时间范围切换流畅,无报错
- 7天显示中文星期(周一到周日)
- 14/30天显示日期格式(01-05等)
- 图表数据来自真实数据库,不是模拟数据
- 图例显示在右侧,包含5种考勤类型

## 注意事项
1. 确保MySQL数据库中有足够的考勤数据用于测试
2. 如果数据库中没有数据,图表会显示"暂无数据"
3. 可以通过"考勤管理"页面添加测试数据
