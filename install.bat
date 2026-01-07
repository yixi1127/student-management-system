@echo off
chcp 65001 >nul
echo ========================================
echo   学生管理系统 - 安装脚本
echo ========================================
echo.

echo [1/2] 安装前端依赖...
call npm install
if errorlevel 1 (
    echo ❌ 前端依赖安装失败
    pause
    exit /b 1
)
echo ✅ 前端依赖安装成功

echo.
echo [2/2] 安装后端依赖...
cd server
call npm install
if errorlevel 1 (
    echo ❌ 后端依赖安装失败
    pause
    exit /b 1
)
echo ✅ 后端依赖安装成功
cd ..

echo.
echo ========================================
echo   安装完成！
echo ========================================
echo.
echo 下一步:
echo 1. 使用 MySQL Workbench 执行 database-mysql.sql
echo 2. 编辑 server/.env 配置数据库密码
echo 3. 运行 start.bat 启动项目
echo.
pause
