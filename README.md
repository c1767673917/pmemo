# PMemo - 现代化备忘录应用

一个使用 React + FastAPI 构建的全栈备忘录应用。

## 特性

- 🚀 现代化技术栈
- 📝 Markdown 支持
- 🎨 优雅的 UI 设计
- 🔍 实时搜索
- 📱 响应式设计
- 🔒 用户认证
- 🌈 标签管理
- 📂 分类功能

## 快速开始

### 使用 Docker（推荐）

```bash
# 克隆项目
git clone https://github.com/yourusername/pmemo.git
cd pmemo

# 启动应用
docker-compose up -d
```

### 手动安装

#### 后端要求
- Python 3.8+
- Poetry

#### 前端要求
- Node.js 16+
- pnpm

#### 安装步骤

1. 安装后端依赖
```bash
cd backend
poetry install
poetry run python main.py
```

2. 安装前端依赖
```bash
cd frontend
pnpm install
pnpm dev
```

## 项目结构

```
pmemo/
├── frontend/          # React 前端应用
├── backend/           # FastAPI 后端服务
├── docker/           # Docker 配置文件
└── scripts/          # 辅助脚本
```

## 技术栈

### 前端
- React 18
- TypeScript
- Vite
- TailwindCSS
- React Query

### 后端
- FastAPI
- SQLAlchemy
- SQLite
- Poetry

## 贡献指南

欢迎提交 Pull Request 和 Issue！

## 许可证

MIT 