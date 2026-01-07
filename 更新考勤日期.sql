-- 更新考勤记录日期为最近的日期
-- 这样可以在Dashboard的考勤统计图表中看到数据

-- 查看当前考勤记录
SELECT student_no, student_name, course_name, attendance_date, type 
FROM attendance 
ORDER BY attendance_date DESC;

-- 更新考勤日期为最近7天内的日期
-- 将所有考勤记录分散到最近7天

-- 方法1: 更新为今天
UPDATE attendance SET attendance_date = CURDATE() WHERE id IN (
  SELECT id FROM (SELECT id FROM attendance LIMIT 2) AS temp
);

-- 方法2: 更新为昨天
UPDATE attendance SET attendance_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY) WHERE id IN (
  SELECT id FROM (SELECT id FROM attendance LIMIT 2 OFFSET 2) AS temp
);

-- 方法3: 批量更新所有记录到最近7天
UPDATE attendance a
JOIN (
  SELECT 
    id,
    ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM attendance
) ranked ON a.id = ranked.id
SET a.attendance_date = DATE_SUB(CURDATE(), INTERVAL MOD(ranked.rn, 7) DAY);

-- 验证更新结果
SELECT 
  attendance_date,
  COUNT(*) as count,
  GROUP_CONCAT(CONCAT(student_name, '-', type) SEPARATOR ', ') as records
FROM attendance 
GROUP BY attendance_date 
ORDER BY attendance_date DESC;

-- 如果需要添加更多最近的考勤记录
INSERT INTO attendance (student_id, student_no, student_name, course_id, course_name, attendance_date, type, reason, teacher_id, teacher_name)
SELECT 
  student_id,
  student_no,
  student_name,
  course_id,
  course_name,
  CURDATE() as attendance_date,
  '正常' as type,
  NULL as reason,
  teacher_id,
  teacher_name
FROM attendance
LIMIT 4;
