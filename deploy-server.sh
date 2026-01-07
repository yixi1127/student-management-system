#!/bin/bash
# 阿里云服务器一键部署脚本

echo "=========================================="
echo "学生管理系统 - 服务器部署脚本"
echo "=========================================="

# 读取MySQL密码
read -sp "请输入MySQL root密码: " MYSQL_PASSWORD
echo ""

# 1. 导入数据库
echo ""
echo "[1/8] 导入数据库..."
mysql -u root -p"$MYSQL_PASSWORD" student_management < /var/www/student-management-system/database-mariadb.sql
if [ $? -eq 0 ]; then
    echo "✓ 数据库导入成功"
else
    echo "✗ 数据库导入失败"
    exit 1
fi

# 2. 配置后端环境变量
echo ""
echo "[2/8] 配置后端环境变量..."
cd /var/www/student-management-system/server
cat > .env << EOF
PORT=3001
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=$MYSQL_PASSWORD
DB_NAME=student_management
JWT_SECRET=your-secret-key-change-this-in-production
JWT_EXPIRES_IN=7d
EOF
echo "✓ 环境变量配置完成"

# 3. 安装后端依赖
echo ""
echo "[3/8] 安装后端依赖..."
npm install
if [ $? -eq 0 ]; then
    echo "✓ 后端依赖安装成功"
else
    echo "✗ 后端依赖安装失败"
    exit 1
fi

# 4. 安装PM2
echo ""
echo "[4/8] 安装PM2进程管理器..."
npm install -g pm2
echo "✓ PM2安装完成"

# 5. 启动后端服务
echo ""
echo "[5/8] 启动后端服务..."
pm2 delete student-api 2>/dev/null
pm2 start index.js --name student-api
pm2 save
pm2 startup
echo "✓ 后端服务启动成功"

# 6. 获取服务器IP
SERVER_IP=$(curl -s ifconfig.me)
echo ""
echo "[6/8] 服务器IP: $SERVER_IP"

# 7. 修改前端API地址
echo ""
echo "[7/8] 配置前端API地址..."
cd /var/www/student-management-system
sed -i "s|baseURL: import.meta.env.VITE_API_BASE_URL \|\| '/api'|baseURL: 'http://$SERVER_IP:3001/api'|g" src/utils/request.js
echo "✓ 前端API地址配置完成"

# 8. 构建前端
echo ""
echo "[8/8] 构建前端项目..."
npm install
npm run build
if [ $? -eq 0 ]; then
    echo "✓ 前端构建成功"
else
    echo "✗ 前端构建失败"
    exit 1
fi

echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo ""
echo "后端服务: http://$SERVER_IP:3001"
echo "前端文件: /var/www/student-management-system/dist"
echo ""
echo "下一步："
echo "1. 安装Nginx: yum install -y nginx"
echo "2. 配置Nginx反向代理"
echo "3. 开放防火墙端口: 80, 3001"
echo "4. 配置阿里云安全组"
echo ""
echo "查看后端日志: pm2 logs student-api"
echo "重启后端: pm2 restart student-api"
echo ""
