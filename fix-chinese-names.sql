USE student_management;

SET NAMES utf8mb4;

UPDATE students SET real_name = '张三' WHERE student_no = '2024001';
UPDATE students SET real_name = '李四' WHERE student_no = '2024002';
UPDATE students SET real_name = '王五' WHERE student_no = '2024003';
UPDATE students SET real_name = '赵六' WHERE student_no = '2024004';

SELECT student_no, real_name, grade, class FROM students;
