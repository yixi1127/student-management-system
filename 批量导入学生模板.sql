-- 批量导入学生模板
-- 使用方法: 在MySQL Workbench中执行此SQL

-- 第一步: 批量插入用户账号
INSERT INTO users (id, email, password, real_name, phone, role, status) VALUES
(UUID(), 'student10@example.com', '123456', '学生10', '13800138010', 'student', 1),
(UUID(), 'student11@example.com', '123456', '学生11', '13800138011', 'student', 1),
(UUID(), 'student12@example.com', '123456', '学生12', '13800138012', 'student', 1);

-- 第二步: 批量插入学生信息
-- 注意: 需要先查询上面插入的用户ID,然后替换下面的user_id
-- 查询刚才插入的用户ID:
-- SELECT id, email, real_name FROM users WHERE email LIKE 'student1%@example.com' ORDER BY created_at DESC LIMIT 3;

-- 然后执行插入(替换user_id为实际的UUID):
-- INSERT INTO students (user_id, student_no, grade, class, gender, address, emergency_contact) VALUES
-- ('替换为user_id', '2024010', '2024', '计算机1班', '男', '北京市', '13900139010'),
-- ('替换为user_id', '2024011', '2024', '计算机1班', '女', '上海市', '13900139011'),
-- ('替换为user_id', '2024012', '2024', '计算机2班', '男', '广州市', '13900139012');

-- 简化方法: 使用子查询直接插入
INSERT INTO students (user_id, student_no, grade, class, gender, address, emergency_contact)
SELECT 
    u.id,
    CASE 
        WHEN u.email = 'student10@example.com' THEN '2024010'
        WHEN u.email = 'student11@example.com' THEN '2024011'
        WHEN u.email = 'student12@example.com' THEN '2024012'
    END as student_no,
    '2024' as grade,
    CASE 
        WHEN u.email IN ('student10@example.com', 'student11@example.com') THEN '计算机1班'
        ELSE '计算机2班'
    END as class,
    CASE 
        WHEN u.email IN ('student10@example.com', 'student12@example.com') THEN '男'
        ELSE '女'
    END as gender,
    CASE 
        WHEN u.email = 'student10@example.com' THEN '北京市海淀区'
        WHEN u.email = 'student11@example.com' THEN '上海市浦东新区'
        ELSE '广州市天河区'
    END as address,
    CONCAT('139001390', RIGHT(u.phone, 2)) as emergency_contact
FROM users u
WHERE u.email IN ('student10@example.com', 'student11@example.com', 'student12@example.com');

-- 验证插入结果
SELECT 
    s.student_no,
    u.real_name,
    s.gender,
    s.grade,
    s.class,
    u.phone,
    u.email
FROM students s
LEFT JOIN users u ON s.user_id = u.id
WHERE s.student_no IN ('2024010', '2024011', '2024012');
