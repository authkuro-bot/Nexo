import { beforeEach, describe, expect, it, vi } from 'vitest';
import { APP_CONFIG } from '@/lib/constants';
import { useChatStore } from './chatStore';

function createSseResponse(events: string[]) {
  const encoder = new TextEncoder();
  const body = new ReadableStream<Uint8Array>({
    start(controller) {
      events.forEach((event) => controller.enqueue(encoder.encode(event)));
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

function createErrorResponse(status: number, error: string) {
  return {
    ok: false,
    status,
    body: null,
    json: async () => ({ error }),
  } as unknown as Response;
}

describe('chatStore', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    useChatStore.setState({
      sessions: {},
      welcomes: {},
      welcomeLoading: {},
      welcomeErrors: {},
      requests: {},
      dailyCount: 0,
    });
  });

  it('moves from analyzing to a completed streamed answer', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(createSseResponse([
      'data: {"chunk":"Jawaban "}\n\n',
      'data: {"chunk":"Nexo"}\n\n',
      'data: [DONE]\n\n',
    ])));

    const requestPromise = useChatStore.getState().streamChat('trend-1', 'Apa peluangnya?');
    expect(useChatStore.getState().requests['trend-1']?.phase).toBe('analyzing');
    expect(useChatStore.getState().sessions['trend-1']?.messages).toHaveLength(1);

    await requestPromise;

    const state = useChatStore.getState();
    expect(state.requests['trend-1']?.phase).toBe('idle');
    expect(state.sessions['trend-1']?.messages).toHaveLength(2);
    expect(state.sessions['trend-1']?.messages[1]).toMatchObject({
      role: 'assistant',
      content: 'Jawaban Nexo',
      status: 'complete',
    });
    expect(state.dailyCount).toBe(1);
  });

  it('retries a failed request without duplicating the user message', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(createErrorResponse(503, 'Layanan AI sibuk'))
      .mockResolvedValueOnce(createSseResponse([
        'data: {"chunk":"Berhasil setelah retry"}\n\n',
        'data: [DONE]\n\n',
      ]));
    vi.stubGlobal('fetch', fetchMock);

    await useChatStore.getState().streamChat('trend-2', 'Coba analisis');
    expect(useChatStore.getState().requests['trend-2']).toMatchObject({
      phase: 'failed',
      retryable: true,
    });

    await useChatStore.getState().retryFailedChat('trend-2');

    const messages = useChatStore.getState().sessions['trend-2']?.messages ?? [];
    expect(messages.filter((message) => message.role === 'user')).toHaveLength(1);
    expect(messages.filter((message) => message.role === 'assistant')).toHaveLength(1);
    expect(messages[1]?.content).toBe('Berhasil setelah retry');
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('marks a partial answer as failed when SSE returns an error', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(createSseResponse([
      'data: {"chunk":"Jawaban parsial"}\n\n',
      'data: {"error":"Stream terputus","code":"AI_STREAM_FAILED"}\n\n',
      'data: [DONE]\n\n',
    ])));

    await useChatStore.getState().streamChat('trend-3', 'Lanjutkan');

    const state = useChatStore.getState();
    expect(state.requests['trend-3']).toMatchObject({
      phase: 'failed',
      retryable: true,
      error: 'Stream terputus',
    });
    expect(state.sessions['trend-3']?.messages[1]).toMatchObject({
      content: 'Jawaban parsial',
      status: 'failed',
    });
    expect(state.dailyCount).toBe(0);
  });

  it('does not offer retry when the daily limit is reached', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(
      createErrorResponse(429, 'Batas 20 chat per hari tercapai. Coba lagi besok.'),
    ));

    await useChatStore.getState().streamChat('trend-4', 'Pertanyaan terakhir');

    expect(useChatStore.getState().requests['trend-4']).toMatchObject({
      phase: 'failed',
      retryable: false,
    });
    expect(useChatStore.getState().dailyCount).toBe(APP_CONFIG.maxChatsPerDay);
  });

  it('retries a failed welcome request', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(createErrorResponse(503, 'Pembuka gagal'))
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          data: {
            welcome: {
              title: 'Halo',
              subtitle: 'Mari membahas tren.',
              suggestions: ['Apa risikonya?'],
            },
          },
        }),
      } as Response);
    vi.stubGlobal('fetch', fetchMock);

    await useChatStore.getState().fetchWelcome('trend-5');
    expect(useChatStore.getState().welcomeErrors['trend-5']).toBe('Pembuka gagal');

    await useChatStore.getState().retryWelcome('trend-5');
    expect(useChatStore.getState().welcomes['trend-5']?.title).toBe('Halo');
    expect(useChatStore.getState().welcomeErrors['trend-5']).toBeNull();
  });
});
