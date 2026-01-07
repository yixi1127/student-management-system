@echo off
chcp 65001 >nul
echo ========================================
echo   学生管理系统 - 启动脚本
echo ========================================
echo.

echo [1/3] 检查 Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未安装 Node.js，请先安装
    pause
    exit /b 1
)
echo ✅ Node.js 已安装

echo.
echo [2/3] 启动后端服务...
cd server
start "后端服务" cmd /k "npm run dev"
cd ..

echo.
echo [3/3] 启动前端服务...
timeout /t 3 /nobreak >nul
start "前端服务" cmd /k "npm run dev"

echo.
echo ========================================
echo   启动完成！
echo ========================================
echo.
echo 后端地址: http://localhost:3001
echo 前端地址: http://localhost:3000
echo.
echo 测试账号:
echo   管理员: admin@example.com / 123456
echo   教师: teacher1@example.com / 123456
echo   学生: zhangsan@example.com / 123456
echo.
echo 按任意键关闭此窗口...
pause >nul
