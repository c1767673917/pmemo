import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { memoApi, tagApi } from '../utils/api';
import type { CreateMemoData } from '../utils/api';

interface Tag {
  id: number;
  name: string;
  color: string;
}

export default function MemoEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const isEdit = Boolean(id);

  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [selectedTags, setSelectedTags] = useState<number[]>([]);
  const [isPublic, setIsPublic] = useState(false);

  // 获取备忘录详情
  const { isLoading: isMemoLoading } = useQuery({
    queryKey: ['memo', id],
    queryFn: async () => {
      if (!id) return null;
      const response = await memoApi.get(parseInt(id));
      const memo = response.data;
      setTitle(memo.title);
      setContent(memo.content);
      setIsPublic(memo.is_public);
      setSelectedTags(memo.tags.map((tag: Tag) => tag.id));
      return memo;
    },
    enabled: isEdit,
  });

  // 获取标签列表
  const { data: tags = [] } = useQuery<Tag[]>({
    queryKey: ['tags'],
    queryFn: async () => {
      const response = await tagApi.list();
      return response.data;
    },
  });

  // 创建备忘录
  const createMutation = useMutation({
    mutationFn: (data: CreateMemoData) => memoApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['memos'] });
      navigate('/');
    },
  });

  // 更新备忘录
  const updateMutation = useMutation({
    mutationFn: (data: CreateMemoData) => memoApi.update(parseInt(id!), data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['memos'] });
      navigate('/');
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const data = {
      title,
      content,
      is_public: isPublic,
      tags: selectedTags,
    };

    if (isEdit) {
      await updateMutation.mutateAsync(data);
    } else {
      await createMutation.mutateAsync(data);
    }
  };

  const handleTagToggle = (tagId: number) => {
    setSelectedTags((prev) =>
      prev.includes(tagId)
        ? prev.filter((id) => id !== tagId)
        : [...prev, tagId]
    );
  };

  if (isMemoLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-500">加载中...</div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label htmlFor="title" className="label">
          标题
        </label>
        <input
          type="text"
          id="title"
          className="input mt-1"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
        />
      </div>

      <div>
        <label htmlFor="content" className="label">
          内容
        </label>
        <textarea
          id="content"
          rows={10}
          className="input mt-1 font-mono"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          required
        />
      </div>

      <div>
        <label className="label">标签</label>
        <div className="mt-2 flex flex-wrap gap-2">
          {tags.map((tag) => (
            <button
              key={tag.id}
              type="button"
              className={`inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium transition-colors ${
                selectedTags.includes(tag.id)
                  ? 'bg-indigo-100 text-indigo-700'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
              onClick={() => handleTagToggle(tag.id)}
            >
              {tag.name}
            </button>
          ))}
        </div>
      </div>

      <div className="flex items-center">
        <input
          type="checkbox"
          id="is-public"
          className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
          checked={isPublic}
          onChange={(e) => setIsPublic(e.target.checked)}
        />
        <label htmlFor="is-public" className="ml-2 block text-sm text-gray-900">
          公开分享
        </label>
      </div>

      <div className="flex justify-end space-x-4">
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => navigate('/')}
        >
          取消
        </button>
        <button type="submit" className="btn btn-primary">
          {isEdit ? '保存' : '创建'}
        </button>
      </div>
    </form>
  );
} 