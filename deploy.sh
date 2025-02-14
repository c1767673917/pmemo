#!/bin/bash

echo "开始部署 PMemo 应用..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
  echo "请使用root权限运行此脚本"
  exit 1
fi

# 更新系统
echo "更新系统..."
apt update && apt upgrade -y

# 安装必要的依赖
echo "安装依赖..."
apt install -y curl git docker.io docker-compose

# 启动docker服务
systemctl start docker
systemctl enable docker

# 安装项目
echo "克隆项目..."
cd /opt
git clone https://github.com/c1767673917/pmemo.git
cd pmemo

# 创建必要的目录和文件
mkdir -p ./data/db
touch .env

# 配置环境变量
cat > .env << EOL
PROJECT_NAME=PMemo
SECRET_KEY=$(openssl rand -hex 32)
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=admin
EOL

# 创建后端 Dockerfile
cat > backend/Dockerfile << EOL
FROM python:3.8-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建数据目录
RUN mkdir -p /app/data

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOL

# 创建 requirements.txt
cat > backend/requirements.txt << EOL
fastapi==0.68.1
uvicorn==0.15.0
sqlalchemy==1.4.23
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.5
pydantic==1.8.2
python-dotenv==0.19.0
aiosqlite==0.17.0
email-validator==1.1.3
python-slugify==5.0.2
EOL

# 启动应用
echo "启动应用..."
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

echo "
PMemo 部署完成！

访问地址：
- 前端: http://YOUR_SERVER_IP:3000
- 后端API: http://YOUR_SERVER_IP:8000
- API文档: http://YOUR_SERVER_IP:8000/docs

默认管理员账号：
- 邮箱: admin@example.com
- 密码: admin

请及时修改默认密码！
" 