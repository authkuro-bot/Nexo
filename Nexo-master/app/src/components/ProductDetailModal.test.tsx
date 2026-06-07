import { act, render, screen } from '@testing-library/react';
import type { ReactNode } from 'react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Trend } from '@/types';

const mocks = vi.hoisted(() => ({
  setSelectedTrend: vi.fn(),
  toastError: vi.fn(),
}));

const trend: Trend = {
  id: 'trend-loading-test',
  name: 'Produk Uji',
  category: 'rumah tangga',
  growth: 42,
  saturation: 24,
  phase: 'Growing',
  platform: 'TikTok Shop',
  timeDetected: '1 jam lalu',
  windowHours: 27,
  thumbnail: '/test.jpg',
  competitorCount: 12,
  avgPrice: 65000,
  reviewVelocity: 8,
  description: 'Produk yang sedang diuji.',
  recommendation: 'Mulai dengan stok kecil.',
};

vi.mock('@/stores', () => ({
  useTrendStore: () => ({
    selectedTrend: trend,
    setSelectedTrend: mocks.setSelectedTrend,
    trends: [trend],
  }),
}));

vi.mock('sonner', () => ({
  toast: {
    error: mocks.toastError,
  },
}));

vi.mock('@/components/GlossaryTooltip', () => ({
  GlossaryTooltip: ({ children }: { children: ReactNode }) => <>{children}</>,
}));

import ProductDetailModal from './ProductDetailModal';

describe('ProductDetailModal AI insight', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    mocks.setSelectedTrend.mockReset();
    mocks.toastError.mockReset();
  });

  it('shows loading while requesting and then renders the AI recommendation', async () => {
    let resolveFetch: ((value: Response) => void) | undefined;
    const fetchPromise = new Promise<Response>((resolve) => {
      resolveFetch = resolve;
    });
    const fetchMock = vi.fn(() => fetchPromise);
    vi.stubGlobal('fetch', fetchMock);

    render(<ProductDetailModal onClose={vi.fn()} onOpenChat={vi.fn()} />);

    expect(screen.getByRole('status')).toHaveTextContent('Mengolah data tren produk...');
    expect(fetchMock).toHaveBeenCalledWith(
      expect.stringContaining('/ai/trends/trend-loading-test/recommendation'),
      expect.objectContaining({ signal: expect.any(AbortSignal) }),
    );

    await act(async () => {
      resolveFetch?.({
        ok: true,
        json: async () => ({
          data: {
            text: 'Rekomendasi AI',
            promptId: 'trend_recommendation',
            provider: 'test',
            model: 'test',
            runId: 'run-test',
            mode: 'trend',
            structured: {
              decision: 'Aman masuk',
              summary: 'Momentum Produk Uji masih kuat.',
              reasons: ['Pertumbuhan masih sehat.'],
              actions: ['Uji stok kecil hari ini.'],
              risks: ['Pantau kompetitor baru.'],
            },
          },
        }),
      } as Response);
      await fetchPromise;
    });

    expect(await screen.findByText('Momentum Produk Uji masih kuat.')).toBeInTheDocument();
    expect(screen.queryByRole('status')).not.toBeInTheDocument();
  });
});
