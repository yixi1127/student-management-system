-- 学生管理系统数据库结构优化
-- 执行此脚本来优化数据库结构

USE student_management;

-- 1. 检查并删除学生表的外键约束
SET @constraint_name = (
  SELECT CONSTRAINT_NAME 
  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
  WHERE TABLE_SCHEMA = 'student_management' 
  AND TABLE_NAME = 'students' 
  AND COLUMN_NAME = 'user_id' 
  AND REFERENCED_TABLE_NAME IS NOT NULL
  LIMIT 1
);

SET @sql = IF(@constraint_name IS NOT NULL, 
  CONCAT('ALTER TABLE students DROP FOREIGN KEY ', @constraint_name), 
  'SELECT "No foreign key to drop" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. 删除学生表的 user_id 字段（如果存在）
SET @col_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'student_management' 
  AND TABLE_NAME = 'students' 
  AND COLUMN_NAME = 'user_id'
);

SET @sql = IF(@col_exists > 0, 
  'ALTER TABLE students DROP COLUMN user_id', 
  'SELECT "Column user_id does not exist" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. 学生表添加更多必要字段
ALTER TABLE students 
  ADD COLUMN real_name VARCHAR(50) NOT NULL DEFAULT '未设置' COMMENT '真实姓名' AFTER student_no,
  ADD COLUMN phone VARCHAR(20) COMMENT '联系电话' AFTER gender,
  ADD COLUMN email VARCHAR(100) COMMENT '邮箱' AFTER phone,
  ADD COLUMN status TINYINT(1) DEFAULT 1 COMMENT '状态：1在读/0毕业/2休学' AFTER emergency_contact;

-- 4. 成绩表添加年级和班级字段（方便查询）
ALTER TABLE scores 
  ADD COLUMN grade VARCHAR(20) COMMENT '年级' AFTER student_name,
  ADD COLUMN class VARCHAR(20) COMMENT '班级' AFTER grade;

-- 5. 考勤表添加年级和班级字段
ALTER TABLE attendance 
  ADD COLUMN grade VARCHAR(20) COMMENT '年级' AFTER student_name,
  ADD COLUMN class VARCHAR(20) COMMENT '班级' AFTER grade;

-- 6. 课程表添加容量限制
ALTER TABLE courses 
  ADD COLUMN max_students INT DEFAULT 100 COMMENT '最大选课人数' AFTER classroom;

-- 7. 添加索引优化查询性能
CREATE INDEX idx_student_grade_class ON students(grade, class);
CREATE INDEX idx_scores_grade_class ON scores(grade, class);
CREATE INDEX idx_attendance_grade_class ON attendance(grade, class);
CREATE INDEX idx_attendance_date_type ON attendance(attendance_date, type);

-- 8. 更新现有学生数据，确保有真实姓名
UPDATE students 
SET real_name = '未设置'
WHERE real_name IS NULL OR real_name = '';

-- 9. 更新成绩表，添加年级和班级信息
UPDATE scores sc
INNER JOIN students s ON sc.student_id = s.id
SET sc.grade = s.grade, sc.class = s.class
WHERE sc.grade IS NULL OR sc.class IS NULL;

-- 10. 更新考勤表，添加年级和班级信息
UPDATE attendance a
INNER JOIN students s ON a.student_id = s.id
SET a.grade = s.grade, a.class = s.class
WHERE a.grade IS NULL OR a.class IS NULL;

-- 完成提示
SELECT '数据库结构优化完成！' AS message;
