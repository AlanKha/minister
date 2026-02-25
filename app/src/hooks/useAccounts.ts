import { useQuery } from '@tanstack/react-query';
import { getAccounts } from '../api/apiClient';

export function useAccounts() {
  return useQuery({
    queryKey: ['accounts'],
    queryFn: getAccounts,
  });
}
