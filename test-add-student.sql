-- 测试添加学生
-- 先查看users表结构
DESCRIBE users;

-- 查看students表结构  
DESCRIBE students;

-- 手动添加一个测试学生
-- 1. 先添加用户
INSERT INTO users (email, password, real_name, phone, role, status) 
VALUES ('test123@example.com', '123456', '测试学生', '13800138888', 'student', 1);

-- 2. 获取刚才插入的用户ID
SELECT LAST_INSERT_ID() as user_id;

-- 3. 添加学生信息(需要手动替换上面的user_id)
-- INSERT INTO students (user_id, student_no, grade, class, gender, address, emergency_contact) 
-- VALUES (替换为上面的user_id, '2024999', '2024', '测试班', '男', '测试地址', '13900139999');

-- 查看所有学生
SELECT s.*, u.email, u.phone 
FROM students s 
LEFT JOIN users u ON s.user_id = u.id;
