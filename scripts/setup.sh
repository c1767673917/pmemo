#!/bin/bash

echo "开始安装 PMemo..."

# 检查是否安装了 Docker
if ! command -v docker &> /dev/null; then
    echo "未检测到 Docker，请先安装 Docker..."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "未检测到 docker-compose，请先安装 docker-compose..."
    exit 1
fi

# 拉取代码（如果在本地运行则跳过）
# git clone https://github.com/yourusername/pmemo.git
# cd pmemo

# 创建必要的目录
mkdir -p ./data/db

# 构建并启动容器
echo "构建并启动容器..."
docker-compose up --build -d

echo "等待服务启动..."
sleep 10

echo "PMemo 安装完成！"
echo "前端地址: http://localhost:3000"
echo "后端API地址: http://localhost:8000"
echo "API文档地址: http://localhost:8000/docs" 