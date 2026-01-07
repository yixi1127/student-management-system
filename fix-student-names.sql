USE student_management;

-- Fix student names from Unknown to their student numbers or user real names
UPDATE students s
LEFT JOIN users u ON u.email = CONCAT(s.student_no, '@example.com')
SET s.real_name = COALESCE(u.real_name, CONCAT('学生', s.student_no))
WHERE s.real_name = 'Unknown' OR s.real_name IS NULL OR s.real_name = '';

-- Show updated students
SELECT student_no, real_name, grade, class FROM students LIMIT 10;
