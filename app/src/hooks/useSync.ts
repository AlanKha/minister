import { useMutation, useQueryClient } from '@tanstack/react-query';
import { syncAll } from '../api/apiClient';
import { useSyncStore } from '../stores/syncStore';

export function useSync() {
  const qc = useQueryClient();
  const { startSync, finishSync, setError } = useSyncStore();

  return useMutation({
    mutationFn: async () => {
      startSync();
      await syncAll();
    },
    onSuccess: () => {
      finishSync();
      qc.invalidateQueries();
    },
    onError: (err: Error) => {
      setError(err.message);
    },
  });
}
