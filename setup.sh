#!/bin/bash

# 克隆仓库
# git clone <repository-url>
# cd pmemo

# 安装依赖
cd client && npm install && cd ../server && npm install

# 启动Docker容器
cd ..
docker-compose up --build 