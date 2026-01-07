-- 学生管理系统数据库初始化脚本
-- 在 Supabase SQL Editor 中执行此脚本

-- 1. 用户表（扩展 auth.users）
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL DEFAULT 'student',
  real_name VARCHAR(50),
  phone VARCHAR(20),
  email VARCHAR(100),
  avatar_url VARCHAR(255),
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 学生表
CREATE TABLE IF NOT EXISTS public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  student_no VARCHAR(20) UNIQUE NOT NULL,
  grade VARCHAR(20) NOT NULL,
  class VARCHAR(20) NOT NULL,
  gender VARCHAR(10),
  address TEXT,
  emergency_contact VARCHAR(20),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 课程表
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_no VARCHAR(20) UNIQUE NOT NULL,
  course_name VARCHAR(100) NOT NULL,
  credit NUMERIC(2,1) NOT NULL,
  teacher_id UUID REFERENCES public.users(id),
  class_time VARCHAR(100),
  classroom VARCHAR(50),
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 学生选课表
CREATE TABLE IF NOT EXISTS public.student_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT '已选',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, course_id)
);

-- 5. 成绩表
CREATE TABLE IF NOT EXISTS public.scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  usual_score NUMERIC(3,1),
  final_score NUMERIC(3,1),
  total_score NUMERIC(3,1),
  teacher_id UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, course_id)
);

-- 6. 考勤表
CREATE TABLE IF NOT EXISTS public.attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  attendance_date DATE NOT NULL,
  type VARCHAR(20) NOT NULL,
  reason TEXT,
  teacher_id UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. 通知表
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  type VARCHAR(20) NOT NULL,
  sender_id UUID REFERENCES public.users(id),
  receiver_role VARCHAR(20),
  receiver_ids UUID[],
  file_url VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. 通知已读记录表
CREATE TABLE IF NOT EXISTS public.notification_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID REFERENCES public.notifications(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(notification_id, user_id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);
CREATE INDEX IF NOT EXISTS idx_students_student_no ON public.students(student_no);
CREATE INDEX IF NOT EXISTS idx_students_grade_class ON public.students(grade, class);
CREATE INDEX IF NOT EXISTS idx_courses_course_no ON public.courses(course_no);
CREATE INDEX IF NOT EXISTS idx_courses_teacher_id ON public.courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_scores_student_course ON public.scores(student_id, course_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON public.attendance(student_id, attendance_date);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为需要的表添加更新时间触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON public.courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scores_updated_at BEFORE UPDATE ON public.scores
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建成绩自动计算触发器
CREATE OR REPLACE FUNCTION calculate_total_score()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.usual_score IS NOT NULL AND NEW.final_score IS NOT NULL THEN
    NEW.total_score := NEW.usual_score * 0.3 + NEW.final_score * 0.7;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_score_trigger BEFORE INSERT OR UPDATE ON public.scores
  FOR EACH ROW EXECUTE FUNCTION calculate_total_score();

-- 启用行级安全策略 (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_reads ENABLE ROW LEVEL SECURITY;

-- RLS 策略示例（根据实际需求调整）

-- 用户表策略：用户可以查看和更新自己的信息
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 管理员可以查看所有用户
CREATE POLICY "Admins can view all users" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );

-- 学生表策略：学生可以查看自己的信息
CREATE POLICY "Students can view own data" ON public.students
  FOR SELECT USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 管理员可以管理学生信息
CREATE POLICY "Admins can manage students" ON public.students
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );

-- 课程表策略：所有人可以查看启用的课程
CREATE POLICY "Everyone can view active courses" ON public.courses
  FOR SELECT USING (status = true);

-- 教师和管理员可以管理课程
CREATE POLICY "Teachers and admins can manage courses" ON public.courses
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 成绩表策略：学生可以查看自己的成绩
CREATE POLICY "Students can view own scores" ON public.scores
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.students
      WHERE id = student_id AND user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 教师可以录入和修改成绩
CREATE POLICY "Teachers can manage scores" ON public.scores
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 考勤表策略：学生可以查看自己的考勤
CREATE POLICY "Students can view own attendance" ON public.attendance
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.students
      WHERE id = student_id AND user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 教师可以录入考勤
CREATE POLICY "Teachers can manage attendance" ON public.attendance
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 通知表策略：所有人可以查看通知
CREATE POLICY "Everyone can view notifications" ON public.notifications
  FOR SELECT USING (true);

-- 管理员和教师可以发布通知
CREATE POLICY "Admins and teachers can create notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin', 'teacher')
    )
  );

-- 插入测试数据（可选）
-- 注意：实际使用时需要先通过 Supabase Auth 创建用户

-- 示例：插入管理员用户信息（假设已通过 Auth 创建）
-- INSERT INTO public.users (id, role, real_name, email, status)
-- VALUES ('your-user-uuid', 'admin', '管理员', 'admin@example.com', true);
