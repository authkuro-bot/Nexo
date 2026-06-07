import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { useAuthStore } from '@/stores/authStore';
import { useChatStore } from '@/stores/chatStore';
import { useTrendStore } from '@/stores/trendStore';
import type { Trend } from '@/types';
import ChatbotPanel from './ChatbotPanel';

const trend: Trend = {
  id: 'chat-trend',
  name: 'Produk Chat',
  category: 'rumah tangga',
  growth: 35,
  saturation: 25,
  phase: 'Growing',
  platform: 'TikTok Shop',
  timeDetected: '1 jam lalu',
  windowHours: 27,
  thumbnail: '/chat.jpg',
  competitorCount: 12,
  avgPrice: 50000,
  reviewVelocity: 8,
  description: 'Produk untuk pengujian chatbot.',
  recommendation: 'Uji stok kecil.',
};

function createSseResponse() {
  const encoder = new TextEncoder();
  const body = new ReadableStream<Uint8Array>({
    start(controller) {
      controller.enqueue(encoder.encode('data: {"chunk":"Jawaban retry berhasil"}\n\n'));
      controller.enqueue(encoder.encode('data: [DONE]\n\n'));
      controller.close();
    },
  });

  return {
    ok: true,
    status: 200,
    body,
    json: async () => ({}),
  } as Response;
}

function setFailedRequest(retryable: boolean) {
  useChatStore.setState({
    sessions: {
      [trend.id]: {
        trendId: trend.id,
        messages: [{
          id: 'user-message',
          role: 'user',
          content: 'Apa peluangnya?',
          timestamp: new Date().toISOString(),
          status: 'complete',
        }],
      },
    },
    requests: {
      [trend.id]: {
        phase: 'failed',
        trendId: trend.id,
        userMessageId: 'user-message',
        originalMessage: 'Apa peluangnya?',
        error: retryable ? 'Layanan AI sibuk' : 'Batas chat harian tercapai',
        retryable,
      },
    },
    welcomes: {},
    welcomeLoading: {},
    welcomeErrors: {},
    dailyCount: retryable ? 0 : 20,
  });
}

describe('ChatbotPanel retry state', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    useTrendStore.setState({ selectedTrend: trend });
    useAuthStore.setState({ isAuthenticated: true });
  });

  it('retries a failed answer without duplicating the user message', async () => {
    setFailedRequest(true);
    const fetchMock = vi.fn().mockResolvedValue(createSseResponse());
    vi.stubGlobal('fetch', fetchMock);

    render(<ChatbotPanel onClose={vi.fn()} />);

    expect(screen.getByRole('alert')).toHaveTextContent('Layanan AI sibuk');
    fireEvent.click(screen.getByRole('button', { name: 'Coba lagi' }));

    await waitFor(() => {
      expect(screen.getByText('Jawaban retry berhasil')).toBeInTheDocument();
    });

    const messages = useChatStore.getState().sessions[trend.id]?.messages ?? [];
    expect(messages.filter((message) => message.role === 'user')).toHaveLength(1);
    expect(fetchMock).toHaveBeenCalledOnce();
  });

  it('does not show retry for a non-retryable daily limit error', () => {
    setFailedRequest(false);
    render(<ChatbotPanel onClose={vi.fn()} />);

    expect(screen.getByRole('alert')).toHaveTextContent('Batas chat harian tercapai');
    expect(screen.queryByRole('button', { name: 'Coba lagi' })).not.toBeInTheDocument();
  });
});
