import { useQuery } from '@tanstack/react-query';
import { getTransactions, getUncategorizedTransactions } from '../api/apiClient';
import { useTransactionStore } from '../stores/transactionStore';

export function useTransactions() {
  const filters = useTransactionStore((s) => s.filters);
  return useQuery({
    queryKey: ['transactions', filters],
    queryFn: () => getTransactions(filters),
  });
}

export function useUncategorizedTransactions() {
  return useQuery({
    queryKey: ['transactions', 'uncategorized'],
    queryFn: getUncategorizedTransactions,
  });
}
