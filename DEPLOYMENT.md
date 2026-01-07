# 部署指南

本文档详细说明如何将学生管理系统部署到阿里云。

## 前置准备

### 1. 阿里云账号准备
- 注册阿里云账号
- 开通以下服务：
  - ECS（云服务器）
  - OSS（对象存储）
  - CDN（内容分发网络）
  - 域名服务

### 2. Supabase 准备
- 注册 Supabase 账号（或准备自建 Supabase）
- 创建新项目
- 获取项目 URL 和 API Key

## 第一步：配置 Supabase

### 1. 创建数据库表

在 Supabase Dashboard 的 SQL Editor 中执行 `database.sql` 文件中的 SQL 语句。

### 2. 配置认证

1. 进入 Authentication > Settings
2. 配置邮箱认证或其他认证方式
3. 设置重定向 URL

### 3. 配置存储桶

1. 进入 Storage
2. 创建 bucket：`avatars`（用于头像）
3. 创建 bucket：`attachments`（用于附件）
4. 设置存储桶策略

### 4. 获取配置信息

在 Project Settings > API 中获取：
- Project URL
- anon/public key

## 第二步：配置前端项目

### 1. 配置环境变量

编辑 `.env` 文件：

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_BASE_URL=/api
```

### 2. 构建项目

```bash
npm install
npm run build
```

构建完成后，会在项目根目录生成 `dist` 文件夹。

## 第三步：部署到阿里云 OSS

### 1. 创建 OSS Bucket

1. 登录阿里云控制台
2. 进入对象存储 OSS
3. 创建 Bucket
   - 名称：如 `student-system`
   - 区域：选择离用户最近的区域
   - 读写权限：公共读
   - 其他保持默认

### 2. 配置静态网站托管

1. 进入 Bucket 设置
2. 找到"静态网站托管"
3. 开启静态网站托管
4. 设置默认首页：`index.html`
5. 设置默认 404 页：`index.html`（用于 SPA 路由）

### 3. 上传文件

方式一：使用阿里云控制台
1. 进入 Bucket 文件管理
2. 上传 `dist` 目录下的所有文件

方式二：使用 ossutil 工具
```bash
# 安装 ossutil
# 配置 ossutil
ossutil config

# 上传文件
ossutil cp -r dist/ oss://student-system/ --update
```

### 4. 配置 CORS（如果需要）

在 Bucket 设置中配置跨域规则：
```json
[
  {
    "allowedOrigin": ["*"],
    "allowedMethod": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "allowedHeader": ["*"],
    "exposeHeader": [],
    "maxAgeSeconds": 3600
  }
]
```

## 第四步：配置 CDN 加速

### 1. 创建 CDN 域名

1. 进入 CDN 控制台
2. 添加域名
3. 源站类型：OSS 域名
4. 选择刚创建的 OSS Bucket

### 2. 配置 HTTPS

1. 申请 SSL 证书（阿里云提供免费证书）
2. 在 CDN 域名配置中上传证书
3. 开启 HTTPS 强制跳转

### 3. 配置缓存规则

建议配置：
- HTML 文件：不缓存或缓存 5 分钟
- CSS/JS 文件：缓存 7 天
- 图片文件：缓存 30 天

### 4. 配置回源规则

添加回源规则，处理 SPA 路由：
- 404 错误时回源到 `/index.html`

## 第五步：配置域名解析

### 1. 添加 CNAME 记录

在域名解析中添加 CNAME 记录：
- 记录类型：CNAME
- 主机记录：www 或 @
- 记录值：CDN 分配的 CNAME 域名

### 2. 等待生效

DNS 解析通常需要 10 分钟到 24 小时生效。

## 第六步：部署 Supabase（可选，自建方案）

如果选择在阿里云 ECS 上自建 Supabase：

### 1. 准备 ECS 实例

- 配置：4核8G 以上
- 系统：Ubuntu 20.04 或 CentOS 8
- 开放端口：22, 80, 443, 5432, 8000

### 2. 安装 Docker

```bash
# Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3. 部署 Supabase

```bash
# 克隆 Supabase
git clone --depth 1 https://github.com/supabase/supabase
cd supabase/docker

# 复制环境变量文件
cp .env.example .env

# 编辑 .env 文件，修改以下配置：
# - POSTGRES_PASSWORD（数据库密码）
# - JWT_SECRET（JWT 密钥）
# - ANON_KEY 和 SERVICE_ROLE_KEY（使用 Supabase 提供的工具生成）
# - SITE_URL（你的域名）

# 启动服务
docker-compose up -d
```

### 4. 配置 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5. 配置 SSL 证书

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d api.yourdomain.com
```

## 第七步：监控与维护

### 1. 配置阿里云监控

- 开启 ECS 监控
- 配置告警规则（CPU、内存、磁盘使用率）
- 配置日志服务（SLS）

### 2. 定期备份

- 配置 OSS 自动备份
- 配置数据库定期备份
- 保留至少 30 天的备份

### 3. 性能优化

- 监控 CDN 命中率
- 优化图片资源
- 启用 Gzip 压缩
- 使用 HTTP/2

## 常见问题

### 1. 页面刷新后 404

确保 OSS 静态网站托管的 404 页面设置为 `index.html`，或在 CDN 配置回源规则。

### 2. API 跨域问题

检查 Supabase 的 CORS 配置，确保允许你的域名访问。

### 3. 构建失败

检查 Node.js 版本（建议 18+），清除 node_modules 重新安装依赖。

### 4. 登录失败

检查 Supabase 配置是否正确，确认 API Key 和 URL 无误。

## 更新部署

当代码更新后：

```bash
# 1. 拉取最新代码
git pull

# 2. 安装依赖（如有新增）
npm install

# 3. 构建
npm run build

# 4. 上传到 OSS
ossutil cp -r dist/ oss://student-system/ --update

# 5. 刷新 CDN 缓存（可选）
# 在阿里云 CDN 控制台手动刷新
```

## 成本估算

基于中小规模使用（1000 用户以内）：

- ECS（2核4G）：约 ¥100/月
- OSS 存储（50GB）：约 ¥10/月
- CDN 流量（100GB）：约 ¥20/月
- 域名：约 ¥50/年
- SSL 证书：免费

总计：约 ¥130/月

## 技术支持

如遇到部署问题，请参考：
- [阿里云 OSS 文档](https://help.aliyun.com/product/31815.html)
- [阿里云 CDN 文档](https://help.aliyun.com/product/27099.html)
- [Supabase 文档](https://supabase.com/docs)
