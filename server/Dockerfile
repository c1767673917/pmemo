# 使用官方Node.js镜像作为基础镜像
FROM node:14

# 设置工作目录
WORKDIR /usr/src/app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装应用依赖
RUN npm install

# 复制应用代码
COPY . .

# 暴露应用运行的端口
EXPOSE 5000

# 启动应用
CMD ["npm", "start"] 