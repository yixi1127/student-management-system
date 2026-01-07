-- 添加更多选课记录,让选课人数更多样化

-- 查看当前选课情况
SELECT 
    c.course_name,
    COUNT(sc.id) as student_count
FROM courses c
LEFT JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id, c.course_name;

-- 添加更多选课记录(如果你已经添加了新学生,可以使用他们的ID)
-- 示例:让更多学生选择"计算机基础"课程
-- INSERT INTO student_courses (student_id, course_id, status) VALUES
-- ('stu-003', 'course-001', '已选'),  -- 王五也选计算机基础
-- ('stu-004', 'course-001', '已选');  -- 赵六也选计算机基础

-- 这样计算机基础的选课人数就会变成4人

-- 或者让某些课程只有1个学生选课
-- DELETE FROM student_courses WHERE student_id = 'stu-004' AND course_id = 'course-004';
-- 这样Web开发的选课人数就会变成1人

-- 执行后刷新课程管理页面,选课人数会自动更新
