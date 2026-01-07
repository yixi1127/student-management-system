-- 兼容 MariaDB 5.5 的数据库初始化脚本

-- 删除已存在的表
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS users;

-- 创建用户表
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'teacher',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建学生表
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  gender VARCHAR(10),
  birth_date DATE,
  class VARCHAR(50),
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  avatar VARCHAR(255),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建课程表
CREATE TABLE courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_code VARCHAR(20) NOT NULL UNIQUE,
  course_name VARCHAR(100) NOT NULL,
  teacher VARCHAR(50),
  credits INT DEFAULT 0,
  hours INT DEFAULT 0,
  semester VARCHAR(20),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建成绩表
CREATE TABLE scores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  score DECIMAL(5,2),
  exam_date DATE,
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建考勤表
CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'present',
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建通知表
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  type VARCHAR(20) DEFAULT 'info',
  target VARCHAR(20) DEFAULT 'all',
  is_read TINYINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入管理员账号 (密码: admin123)
INSERT INTO users (username, password, role) VALUES 
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKzjgduC', 'admin');

-- 插入示例学生数据
INSERT INTO students (student_id, name, gender, birth_date, class, phone, email, status) VALUES
('2024001', '张三', '男', '2005-03-15', '计算机1班', '13800138001', 'zhangsan@example.com', 'active'),
('2024002', '李四', '女', '2005-06-20', '计算机1班', '13800138002', 'lisi@example.com', 'active'),
('2024003', '王五', '男', '2005-09-10', '计算机2班', '13800138003', 'wangwu@example.com', 'active'),
('2024004', '赵六', '女', '2005-12-05', '计算机2班', '13800138004', 'zhaoliu@example.com', 'active');

-- 插入示例课程数据
INSERT INTO courses (course_code, course_name, teacher, credits, hours, semester) VALUES
('CS101', '计算机基础', '张老师', 3, 48, '2024春季'),
('CS102', '数据结构', '李老师', 4, 64, '2024春季'),
('CS103', '数据库原理', '王老师', 3, 48, '2024春季'),
('CS104', 'Web开发', '赵老师', 4, 64, '2024春季');

-- 插入示例成绩数据
INSERT INTO scores (student_id, course_id, score, exam_date) VALUES
(1, 1, 85.5, '2024-01-15'),
(1, 2, 92.0, '2024-01-16'),
(2, 1, 78.0, '2024-01-15'),
(2, 2, 88.5, '2024-01-16'),
(3, 1, 90.0, '2024-01-15'),
(3, 2, 85.0, '2024-01-16');

-- 插入示例考勤数据
INSERT INTO attendance (student_id, course_id, attendance_date, status) VALUES
(1, 1, '2024-01-08', 'present'),
(1, 1, '2024-01-09', 'present'),
(2, 1, '2024-01-08', 'present'),
(2, 1, '2024-01-09', 'late'),
(3, 1, '2024-01-08', 'absent'),
(3, 1, '2024-01-09', 'present');

-- 插入示例通知数据
INSERT INTO notifications (title, content, type, target) VALUES
('系统上线通知', '学生管理系统已正式上线，欢迎使用！', 'info', 'all'),
('期末考试安排', '期末考试将于下周进行，请各位同学做好准备。', 'warning', 'all');
