#!/bin/bash

echo "PMemo 一键部署脚本"
echo "==================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
  echo "请使用root权限运行此脚本"
  exit 1
fi

# 安装系统依赖
echo "正在安装系统依赖..."
apt update
apt install -y curl git python3 python3-pip nodejs npm nginx

# 安装 Poetry
echo "正在安装 Poetry..."
curl -sSL https://install.python-poetry.org | python3 -

# 安装 pnpm
echo "正在安装 pnpm..."
npm install -g pnpm

# 克隆项目
echo "正在克隆项目..."
git clone https://github.com/yourusername/pmemo.git /opt/pmemo
cd /opt/pmemo

# 后端配置
echo "正在配置后端..."
cd backend
poetry install
poetry run python -m pip install uvicorn

# 创建systemd服务配置
cat > /etc/systemd/system/pmemo-backend.service << EOL
[Unit]
Description=PMemo Backend
After=network.target

[Service]
User=root
WorkingDirectory=/opt/pmemo/backend
Environment="PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/root/.local/bin/poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# 前端配置
echo "正在配置前端..."
cd ../frontend
pnpm install
pnpm build

# 配置Nginx
cat > /etc/nginx/sites-available/pmemo << EOL
server {
    listen 80;
    server_name _;  # 替换为你的域名

    # 前端
    location / {
        root /opt/pmemo/frontend/dist;
        try_files \$uri \$uri/ /index.html;
    }

    # 后端API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

# 启用站点配置
ln -sf /etc/nginx/sites-available/pmemo /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 启动服务
echo "正在启动服务..."
systemctl daemon-reload
systemctl enable pmemo-backend
systemctl start pmemo-backend
systemctl restart nginx

echo "==================="
echo "部署完成！"
echo "前端访问地址: http://your-server-ip"
echo "后端API地址: http://your-server-ip/api"
echo "===================" 