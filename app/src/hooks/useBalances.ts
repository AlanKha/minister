import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { getBalances, refreshBalances } from '../api/apiClient';

export function useBalances() {
  return useQuery({
    queryKey: ['balances'],
    queryFn: getBalances,
  });
}

export function useRefreshBalances() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (accountIds?: string[]) => refreshBalances(accountIds),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['balances'] }),
  });
}
