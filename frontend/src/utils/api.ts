import axios from 'axios';

const API_URL = 'http://localhost:8000/api/v1';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export interface LoginData {
  username: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  full_name: string;
}

export interface CreateMemoData {
  title: string;
  content: string;
  is_public?: boolean;
  tags?: number[];
}

export interface UpdateMemoData extends Partial<CreateMemoData> {}

export interface CreateTagData {
  name: string;
  color?: string;
}

const authApi = {
  login: (data: LoginData) =>
    api.post('/auth/login', data, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    }),
  register: (data: RegisterData) => api.post('/auth/register', data),
  me: () => api.get('/auth/me'),
};

const memoApi = {
  list: () => api.get('/memos'),
  create: (data: CreateMemoData) => api.post('/memos', data),
  get: (id: number) => api.get(`/memos/${id}`),
  update: (id: number, data: UpdateMemoData) => api.put(`/memos/${id}`, data),
  delete: (id: number) => api.delete(`/memos/${id}`),
  search: (query: string) => api.get(`/memos/search?q=${query}`),
};

const tagApi = {
  list: () => api.get('/tags'),
  create: (data: CreateTagData) => api.post('/tags', data),
  update: (id: number, data: CreateTagData) => api.put(`/tags/${id}`, data),
  delete: (id: number) => api.delete(`/tags/${id}`),
};

export { api, authApi, memoApi, tagApi }; 