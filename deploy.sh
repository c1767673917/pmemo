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

# 创建 docker-compose.yml
cat > docker-compose.yml << EOL
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    depends_on:
      - backend
    restart: always

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/data
    environment:
      - DATABASE_URL=sqlite:///./data/pmemo.db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: always
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
# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app

# 复制 package.json
COPY package.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOL

# 创建 nginx.conf
cat > frontend/nginx.conf << EOL
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # 启用gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # 缓存静态资源
    location /assets {
        expires 1y;
        add_header Cache-Control "public, no-transform";
    }

    # 安全相关的响应头
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
}
EOL

# 初始化前端依赖
cd frontend
mkdir -p src
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

# 创建 vite.config.ts
cat > vite.config.ts << EOL
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  }
})
EOL

# 创建 tsconfig.json
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOL

# 创建 tsconfig.node.json
cat > tsconfig.node.json << EOL
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOL

# 创建 index.html
cat > index.html << EOL
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PMemo - 现代化备忘录</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOL

# 创建 src/main.tsx
mkdir -p src
cat > src/main.tsx << EOL
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOL

# 创建 src/index.css
cat > src/index.css << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
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