-- 将指定邮箱的用户角色更新为管理员
UPDATE users SET role = 'admin' WHERE email = '1575364853@qq.com';

-- 查看更新结果
SELECT id, email, real_name, role, created_at FROM users WHERE email = '1575364853@qq.com';
