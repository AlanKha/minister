import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  clearCategoryRules,
  clearOverrides,
  clearPins,
  clearTransactions,
  getStats,
  recategorize,
  resetCategoryRules,
  unlinkAccounts,
} from '../api/apiClient';

export function useStats() {
  return useQuery({
    queryKey: ['stats'],
    queryFn: getStats,
  });
}

function makeAdminMutation(fn: () => Promise<void>, invalidateAll = true) {
  return (qc: ReturnType<typeof useQueryClient>) =>
    useMutation({
      mutationFn: fn,
      onSuccess: invalidateAll
        ? () => qc.invalidateQueries()
        : undefined,
    });
}

export function useResetCategoryRules() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: resetCategoryRules,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['categoryRules'] });
      qc.invalidateQueries({ queryKey: ['transactions'] });
    },
  });
}

export function useClearCategoryRules() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: clearCategoryRules,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categoryRules'] }),
  });
}

export function useRecategorize() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: recategorize,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['transactions'] }),
  });
}

export function useClearOverrides() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: clearOverrides,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['transactions'] }),
  });
}

export function useClearPins() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: clearPins,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['transactions'] }),
  });
}

export function useClearTransactions() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: clearTransactions,
    onSuccess: () => qc.invalidateQueries(),
  });
}

export function useUnlinkAccounts() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: unlinkAccounts,
    onSuccess: () => qc.invalidateQueries(),
  });
}
