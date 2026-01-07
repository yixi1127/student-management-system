-- 为学生表添加出生日期字段
ALTER TABLE students ADD COLUMN birth_date DATE COMMENT '出生日期' AFTER gender;

-- 为现有学生添加示例出生日期
UPDATE students SET birth_date = '2005-03-15' WHERE student_no = '2025005';
UPDATE students SET birth_date = '2004-06-20' WHERE student_no = '2024001';
UPDATE students SET birth_date = '2004-09-08' WHERE student_no = '2024002';
UPDATE students SET birth_date = '2004-11-25' WHERE student_no = '2024003';
UPDATE students SET birth_date = '2004-02-14' WHERE student_no = '2024004';
