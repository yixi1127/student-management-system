USE student_management;

-- 为现有学生设置示例姓名
-- 你可以根据实际情况修改这些姓名

UPDATE students SET real_name = '张三' WHERE student_no = '11111111';
UPDATE students SET real_name = '李四' WHERE student_no = '2024001';
UPDATE students SET real_name = '王五' WHERE student_no = '2024002';
UPDATE students SET real_name = '赵六' WHERE student_no = '2024003';
UPDATE students SET real_name = '钱七' WHERE student_no = '2024004';

-- 查看更新结果
SELECT student_no, real_name, grade, class FROM students;

-- 如果你想批量设置，可以使用这个模板：
-- UPDATE students SET real_name = '姓名' WHERE student_no = '学号';
