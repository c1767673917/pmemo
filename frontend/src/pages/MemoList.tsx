import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { memoApi } from '../utils/api';

interface Memo {
  id: number;
  title: string;
  content: string;
  created_at: string;
  updated_at: string;
  tags: Array<{
    id: number;
    name: string;
    color: string;
  }>;
}

export default function MemoList() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');

  const { data: memos = [], isLoading } = useQuery<Memo[]>({
    queryKey: ['memos', searchQuery],
    queryFn: async () => {
      const response = searchQuery
        ? await memoApi.search(searchQuery)
        : await memoApi.list();
      return response.data;
    },
  });

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-500">加载中...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div className="flex-1 max-w-lg">
          <input
            type="text"
            placeholder="搜索备忘录..."
            className="input"
            value={searchQuery}
            onChange={handleSearch}
          />
        </div>
        <button
          onClick={() => navigate('/memo/new')}
          className="btn btn-primary"
        >
          新建备忘录
        </button>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {memos.map((memo) => (
          <div
            key={memo.id}
            className="bg-white rounded-lg shadow hover:shadow-md transition-shadow cursor-pointer"
            onClick={() => navigate(`/memo/${memo.id}`)}
          >
            <div className="p-6">
              <div className="flex justify-between items-start">
                <h3 className="text-lg font-medium text-gray-900 truncate">
                  {memo.title}
                </h3>
                <span className="text-sm text-gray-500">
                  {format(new Date(memo.updated_at || memo.created_at), 'MM/dd HH:mm')}
                </span>
              </div>
              <p className="mt-2 text-gray-600 line-clamp-3">{memo.content}</p>
              {memo.tags.length > 0 && (
                <div className="mt-4 flex flex-wrap gap-2">
                  {memo.tags.map((tag) => (
                    <span
                      key={tag.id}
                      className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium"
                      style={{
                        backgroundColor: `${tag.color}20`,
                        color: tag.color,
                      }}
                    >
                      {tag.name}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {memos.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">
            {searchQuery ? '没有找到匹配的备忘录' : '还没有创建任何备忘录'}
          </p>
        </div>
      )}
    </div>
  );
} 