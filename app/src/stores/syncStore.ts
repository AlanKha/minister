import { create } from 'zustand';

type SyncStatus = 'idle' | 'syncing' | 'done' | 'error';

interface SyncStore {
  status: SyncStatus;
  errorMessage?: string;
  startSync(): void;
  finishSync(): void;
  setError(msg: string): void;
  reset(): void;
}

export const useSyncStore = create<SyncStore>((set) => ({
  status: 'idle',

  startSync() {
    set({ status: 'syncing', errorMessage: undefined });
  },

  finishSync() {
    set({ status: 'done' });
    setTimeout(() => set({ status: 'idle' }), 3000);
  },

  setError(msg) {
    set({ status: 'error', errorMessage: msg });
    setTimeout(() => set({ status: 'idle', errorMessage: undefined }), 5000);
  },

  reset() {
    set({ status: 'idle', errorMessage: undefined });
  },
}));
