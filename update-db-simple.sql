USE student_management;

-- Add real_name column to students if not exists
ALTER TABLE students ADD COLUMN real_name VARCHAR(50) NOT NULL DEFAULT 'Unknown' AFTER student_no;

-- Add phone column to students if not exists  
ALTER TABLE students ADD COLUMN phone VARCHAR(20) AFTER gender;

-- Add email column to students if not exists
ALTER TABLE students ADD COLUMN email VARCHAR(100) AFTER phone;

-- Add status column to students if not exists
ALTER TABLE students ADD COLUMN status TINYINT(1) DEFAULT 1 AFTER emergency_contact;

-- Add grade and class to scores table
ALTER TABLE scores ADD COLUMN grade VARCHAR(20) AFTER student_name;
ALTER TABLE scores ADD COLUMN class VARCHAR(20) AFTER grade;

-- Add grade and class to attendance table
ALTER TABLE attendance ADD COLUMN grade VARCHAR(20) AFTER student_name;
ALTER TABLE attendance ADD COLUMN class VARCHAR(20) AFTER grade;

-- Add max_students to courses table
ALTER TABLE courses ADD COLUMN max_students INT DEFAULT 100 AFTER classroom;

-- Create indexes
CREATE INDEX idx_student_grade_class ON students(grade, class);
CREATE INDEX idx_scores_grade_class ON scores(grade, class);
CREATE INDEX idx_attendance_grade_class ON attendance(grade, class);
CREATE INDEX idx_attendance_date_type ON attendance(attendance_date, type);

-- Update existing data
UPDATE students SET real_name = 'Unknown' WHERE real_name IS NULL OR real_name = '';

UPDATE scores sc
INNER JOIN students s ON sc.student_id = s.id
SET sc.grade = s.grade, sc.class = s.class
WHERE sc.grade IS NULL OR sc.class IS NULL;

UPDATE attendance a
INNER JOIN students s ON a.student_id = s.id
SET a.grade = s.grade, a.class = s.class
WHERE a.grade IS NULL OR a.class IS NULL;

SELECT 'Database update completed!' AS message;
