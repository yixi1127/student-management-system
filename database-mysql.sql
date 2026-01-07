-- 学生管理系统 MySQL 数据库初始化脚本
-- 在 MySQL Workbench 中执行此脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS student_management DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_management;

-- 1. 用户表
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  role VARCHAR(20) NOT NULL DEFAULT 'student' COMMENT '角色：super_admin/admin/teacher/student',
  real_name VARCHAR(50) COMMENT '真实姓名',
  phone VARCHAR(20) COMMENT '手机号',
  email VARCHAR(100) UNIQUE NOT NULL COMMENT '邮箱',
  password VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  avatar_url VARCHAR(255) COMMENT '头像URL',
  status TINYINT(1) DEFAULT 1 COMMENT '状态：1启用/0禁用',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_role (role),
  INDEX idx_status (status),
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 学生表
CREATE TABLE IF NOT EXISTS students (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id VARCHAR(36) COMMENT '关联用户ID',
  student_no VARCHAR(20) UNIQUE NOT NULL COMMENT '学号',
  grade VARCHAR(20) NOT NULL COMMENT '年级',
  class VARCHAR(20) NOT NULL COMMENT '班级',
  gender VARCHAR(10) COMMENT '性别',
  address TEXT COMMENT '家庭地址',
  emergency_contact VARCHAR(20) COMMENT '紧急联系人电话',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_student_no (student_no),
  INDEX idx_grade_class (grade, class)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

-- 3. 课程表
CREATE TABLE IF NOT EXISTS courses (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  course_no VARCHAR(20) UNIQUE NOT NULL COMMENT '课程编号',
  course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
  credit DECIMAL(2,1) NOT NULL COMMENT '学分',
  teacher_id VARCHAR(36) COMMENT '授课教师ID',
  teacher_name VARCHAR(50) COMMENT '授课教师姓名',
  class_time VARCHAR(100) COMMENT '上课时间',
  classroom VARCHAR(50) COMMENT '上课地点',
  status TINYINT(1) DEFAULT 1 COMMENT '状态：1启用/0停用',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_course_no (course_no),
  INDEX idx_teacher_id (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- 4. 学生选课表
CREATE TABLE IF NOT EXISTS student_courses (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  student_id VARCHAR(36) NOT NULL,
  course_id VARCHAR(36) NOT NULL,
  status VARCHAR(20) DEFAULT '已选' COMMENT '选课状态',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  UNIQUE KEY uk_student_course (student_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生选课表';

-- 5. 成绩表
CREATE TABLE IF NOT EXISTS scores (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  student_id VARCHAR(36) NOT NULL,
  student_no VARCHAR(20) COMMENT '学号',
  student_name VARCHAR(50) COMMENT '学生姓名',
  course_id VARCHAR(36) NOT NULL,
  course_name VARCHAR(100) COMMENT '课程名称',
  usual_score DECIMAL(5,2) COMMENT '平时分',
  final_score DECIMAL(5,2) COMMENT '期末分',
  total_score DECIMAL(5,2) COMMENT '总分',
  teacher_id VARCHAR(36) COMMENT '录入教师ID',
  teacher_name VARCHAR(50) COMMENT '录入教师姓名',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY uk_student_course (student_id, course_id),
  INDEX idx_student_course (student_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成绩表';

-- 6. 考勤表
CREATE TABLE IF NOT EXISTS attendance (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  student_id VARCHAR(36) NOT NULL,
  student_no VARCHAR(20) COMMENT '学号',
  student_name VARCHAR(50) COMMENT '学生姓名',
  course_id VARCHAR(36) NOT NULL,
  course_name VARCHAR(100) COMMENT '课程名称',
  attendance_date DATE NOT NULL COMMENT '考勤日期',
  type VARCHAR(20) NOT NULL COMMENT '考勤类型：正常/迟到/早退/旷课/请假',
  reason TEXT COMMENT '原因',
  teacher_id VARCHAR(36) COMMENT '录入教师ID',
  teacher_name VARCHAR(50) COMMENT '录入教师姓名',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_date (student_id, attendance_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤表';

-- 7. 通知表
CREATE TABLE IF NOT EXISTS notifications (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  title VARCHAR(100) NOT NULL COMMENT '通知标题',
  content TEXT NOT NULL COMMENT '通知内容',
  type VARCHAR(20) NOT NULL COMMENT '通知类型：系统/课程',
  sender_id VARCHAR(36) COMMENT '发送人ID',
  sender_name VARCHAR(50) COMMENT '发送人姓名',
  receiver_role VARCHAR(20) COMMENT '接收角色：all/student/teacher/admin',
  file_url VARCHAR(255) COMMENT '附件URL',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

-- 8. 通知已读记录表
CREATE TABLE IF NOT EXISTS notification_reads (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  notification_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uk_notification_user (notification_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知已读记录表';

-- 插入测试数据

-- 插入管理员账号（密码：123456，实际使用时应该加密）
INSERT INTO users (id, role, real_name, phone, email, password, status) VALUES
('admin-001', 'admin', '系统管理员', '13800138000', 'admin@example.com', '123456', 1),
('teacher-001', 'teacher', '王老师', '13800138001', 'teacher1@example.com', '123456', 1),
('teacher-002', 'teacher', '李老师', '13800138002', 'teacher2@example.com', '123456', 1);

-- 插入学生用户
INSERT INTO users (id, role, real_name, phone, email, password, status) VALUES
('student-001', 'student', '张三', '13900139001', 'zhangsan@example.com', '123456', 1),
('student-002', 'student', '李四', '13900139002', 'lisi@example.com', '123456', 1),
('student-003', 'student', '王五', '13900139003', 'wangwu@example.com', '123456', 1),
('student-004', 'student', '赵六', '13900139004', 'zhaoliu@example.com', '123456', 1);

-- 插入学生信息
INSERT INTO students (id, user_id, student_no, grade, class, gender, address, emergency_contact) VALUES
('stu-001', 'student-001', '2024001', '2024', '计算机1班', '男', '北京市海淀区', '13800138100'),
('stu-002', 'student-002', '2024002', '2024', '计算机1班', '女', '上海市浦东新区', '13800138101'),
('stu-003', 'student-003', '2024003', '2024', '计算机2班', '男', '广州市天河区', '13800138102'),
('stu-004', 'student-004', '2024004', '2024', '计算机2班', '女', '深圳市南山区', '13800138103');

-- 插入课程
INSERT INTO courses (id, course_no, course_name, credit, teacher_id, teacher_name, class_time, classroom, status) VALUES
('course-001', 'CS101', '计算机基础', 3.0, 'teacher-001', '王老师', '周一1-2节', 'A101', 1),
('course-002', 'CS102', '数据结构', 4.0, 'teacher-001', '王老师', '周二3-4节', 'A102', 1),
('course-003', 'CS103', '数据库原理', 3.5, 'teacher-002', '李老师', '周三1-2节', 'B201', 1),
('course-004', 'CS104', 'Web开发', 3.0, 'teacher-002', '李老师', '周四3-4节', 'B202', 1);

-- 插入选课记录
INSERT INTO student_courses (student_id, course_id, status) VALUES
('stu-001', 'course-001', '已选'),
('stu-001', 'course-002', '已选'),
('stu-002', 'course-001', '已选'),
('stu-002', 'course-003', '已选'),
('stu-003', 'course-002', '已选'),
('stu-003', 'course-004', '已选'),
('stu-004', 'course-003', '已选'),
('stu-004', 'course-004', '已选');

-- 插入成绩
INSERT INTO scores (student_id, student_no, student_name, course_id, course_name, usual_score, final_score, total_score, teacher_id, teacher_name) VALUES
('stu-001', '2024001', '张三', 'course-001', '计算机基础', 85.0, 90.0, 88.5, 'teacher-001', '王老师'),
('stu-001', '2024001', '张三', 'course-002', '数据结构', 88.0, 92.0, 90.8, 'teacher-001', '王老师'),
('stu-002', '2024002', '李四', 'course-001', '计算机基础', 90.0, 88.0, 88.6, 'teacher-001', '王老师'),
('stu-002', '2024002', '李四', 'course-003', '数据库原理', 85.0, 87.0, 86.4, 'teacher-002', '李老师');

-- 插入考勤记录
INSERT INTO attendance (student_id, student_no, student_name, course_id, course_name, attendance_date, type, reason, teacher_id, teacher_name) VALUES
('stu-001', '2024001', '张三', 'course-001', '计算机基础', '2024-01-05', '正常', NULL, 'teacher-001', '王老师'),
('stu-002', '2024002', '李四', 'course-001', '计算机基础', '2024-01-05', '迟到', '交通堵塞', 'teacher-001', '王老师'),
('stu-003', '2024003', '王五', 'course-002', '数据结构', '2024-01-05', '正常', NULL, 'teacher-001', '王老师'),
('stu-004', '2024004', '赵六', 'course-003', '数据库原理', '2024-01-05', '请假', '身体不适', 'teacher-002', '李老师');

-- 插入通知
INSERT INTO notifications (title, content, type, sender_id, sender_name, receiver_role) VALUES
('期末考试安排通知', '期末考试将于下周开始，请各位同学做好准备...', '系统', 'admin-001', '系统管理员', 'all'),
('寒假放假通知', '寒假放假时间为1月15日至2月20日...', '系统', 'admin-001', '系统管理员', 'all'),
('成绩查询系统开放', '本学期成绩已录入完毕，请登录系统查询...', '系统', 'admin-001', '系统管理员', 'student'),
('下学期选课通知', '下学期选课系统将于2月1日开放...', '系统', 'admin-001', '系统管理员', 'student');

-- 创建视图：学生成绩统计
CREATE OR REPLACE VIEW v_student_scores AS
SELECT 
  st.id AS student_id,
  st.student_no,
  u.real_name AS student_name,
  st.grade,
  st.class,
  COUNT(sc.id) AS total_courses,
  AVG(sc.total_score) AS avg_score,
  SUM(CASE WHEN sc.total_score >= 60 THEN 1 ELSE 0 END) AS pass_count,
  SUM(CASE WHEN sc.total_score < 60 THEN 1 ELSE 0 END) AS fail_count
FROM students st
LEFT JOIN users u ON st.user_id = u.id
LEFT JOIN scores sc ON st.id = sc.student_id
GROUP BY st.id, st.student_no, u.real_name, st.grade, st.class;

-- 创建视图：考勤统计（MySQL 不支持 CREATE OR REPLACE VIEW，需要先删除）
DROP VIEW IF EXISTS v_attendance_stats;
CREATE VIEW v_attendance_stats AS
SELECT 
  st.id AS student_id,
  st.student_no,
  u.real_name AS student_name,
  st.grade,
  st.class,
  COUNT(a.id) AS total_records,
  SUM(CASE WHEN a.type = '正常' THEN 1 ELSE 0 END) AS normal_count,
  SUM(CASE WHEN a.type = '迟到' THEN 1 ELSE 0 END) AS late_count,
  SUM(CASE WHEN a.type = '早退' THEN 1 ELSE 0 END) AS early_count,
  SUM(CASE WHEN a.type = '旷课' THEN 1 ELSE 0 END) AS absent_count,
  SUM(CASE WHEN a.type = '请假' THEN 1 ELSE 0 END) AS leave_count
FROM students st
LEFT JOIN users u ON st.user_id = u.id
LEFT JOIN attendance a ON st.id = a.student_id
GROUP BY st.id, st.student_no, u.real_name, st.grade, st.class;

-- 查询测试
SELECT '=== 用户列表 ===' AS info;
SELECT id, role, real_name, email FROM users;

SELECT '=== 学生列表 ===' AS info;
SELECT s.student_no, u.real_name, s.grade, s.class FROM students s 
LEFT JOIN users u ON s.user_id = u.id;

SELECT '=== 课程列表 ===' AS info;
SELECT course_no, course_name, credit, teacher_name FROM courses;

SELECT '=== 成绩列表 ===' AS info;
SELECT student_no, student_name, course_name, usual_score, final_score, total_score FROM scores;
