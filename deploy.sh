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

# 创建前端 Dockerfile
cat > frontend/Dockerfile << EOL
FROM node:18-alpine

WORKDIR /app

# 安装依赖
COPY package.json ./
RUN npm install

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 使用 nginx 部署
FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOL

# 初始化前端依赖
cd frontend
cat > package.json << EOL
{
  "name": "pmemo-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview"
  },
  "dependencies": {
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^2.0.18",
    "@tanstack/react-query": "^4.36.1",
    "@types/node": "^20.8.2",
    "axios": "^1.6.0",
    "date-fns": "^2.30.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-hook-form": "^7.47.0",
    "react-markdown": "^9.0.0",
    "react-router-dom": "^6.18.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.3",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.5",
    "typescript": "^5.0.2",
    "vite": "^4.4.5"
  }
}
EOL

cd ..

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