import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { tagApi } from '../utils/api';
import type { CreateTagData } from '../utils/api';

interface Tag {
  id: number;
  name: string;
  color: string;
}

const DEFAULT_COLORS = [
  '#1abc9c',
  '#3498db',
  '#9b59b6',
  '#f1c40f',
  '#e67e22',
  '#e74c3c',
  '#34495e',
];

export default function TagManage() {
  const queryClient = useQueryClient();
  const [name, setName] = useState('');
  const [color, setColor] = useState(DEFAULT_COLORS[0]);
  const [editingTag, setEditingTag] = useState<Tag | null>(null);

  const { data: tags = [] } = useQuery<Tag[]>({
    queryKey: ['tags'],
    queryFn: async () => {
      const response = await tagApi.list();
      return response.data;
    },
  });

  const createMutation = useMutation({
    mutationFn: (data: CreateTagData) => tagApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tags'] });
      setName('');
      setColor(DEFAULT_COLORS[0]);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: CreateTagData }) =>
      tagApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tags'] });
      setEditingTag(null);
      setName('');
      setColor(DEFAULT_COLORS[0]);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => tagApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tags'] });
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const data = { name, color };

    if (editingTag) {
      await updateMutation.mutateAsync({ id: editingTag.id, data });
    } else {
      await createMutation.mutateAsync(data);
    }
  };

  const handleEdit = (tag: Tag) => {
    setEditingTag(tag);
    setName(tag.name);
    setColor(tag.color);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('确定要删除这个标签吗？')) {
      await deleteMutation.mutateAsync(id);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="name" className="label">
            标签名称
          </label>
          <input
            type="text"
            id="name"
            className="input mt-1"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>

        <div>
          <label className="label">标签颜色</label>
          <div className="mt-2 flex flex-wrap gap-3">
            {DEFAULT_COLORS.map((c) => (
              <button
                key={c}
                type="button"
                className={`w-8 h-8 rounded-full border-2 ${
                  color === c ? 'border-gray-600' : 'border-transparent'
                }`}
                style={{ backgroundColor: c }}
                onClick={() => setColor(c)}
              />
            ))}
          </div>
        </div>

        <div>
          <button type="submit" className="btn btn-primary">
            {editingTag ? '保存' : '创建'}
          </button>
          {editingTag && (
            <button
              type="button"
              className="ml-4 text-gray-600 hover:text-gray-900"
              onClick={() => {
                setEditingTag(null);
                setName('');
                setColor(DEFAULT_COLORS[0]);
              }}
            >
              取消
            </button>
          )}
        </div>
      </form>

      <div className="border-t pt-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">标签列表</h3>
        <div className="space-y-4">
          {tags.map((tag) => (
            <div
              key={tag.id}
              className="flex items-center justify-between bg-white p-4 rounded-lg shadow-sm"
            >
              <div className="flex items-center space-x-3">
                <div
                  className="w-6 h-6 rounded-full"
                  style={{ backgroundColor: tag.color }}
                />
                <span className="text-gray-900">{tag.name}</span>
              </div>
              <div className="flex items-center space-x-2">
                <button
                  type="button"
                  className="text-gray-600 hover:text-gray-900"
                  onClick={() => handleEdit(tag)}
                >
                  编辑
                </button>
                <button
                  type="button"
                  className="text-red-600 hover:text-red-900"
                  onClick={() => handleDelete(tag.id)}
                >
                  删除
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
} 