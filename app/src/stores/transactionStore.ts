import { create } from 'zustand';
import { TransactionFilters } from '../models/transaction';

interface TransactionStore {
  filters: TransactionFilters;
  setFilter<K extends keyof TransactionFilters>(key: K, value: TransactionFilters[K]): void;
  resetFilters(): void;
}

const DEFAULT_FILTERS: TransactionFilters = {
  sort: 'date_desc',
  page: 1,
};

export const useTransactionStore = create<TransactionStore>((set) => ({
  filters: { ...DEFAULT_FILTERS },

  setFilter(key, value) {
    set((state) => ({
      filters: {
        ...state.filters,
        [key]: value,
        // Reset page when changing any filter except page itself
        ...(key !== 'page' ? { page: 1 } : {}),
      },
    }));
  },

  resetFilters() {
    set({ filters: { ...DEFAULT_FILTERS } });
  },
}));
