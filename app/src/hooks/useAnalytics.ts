import { useQuery } from '@tanstack/react-query';
import { AnalyticsParams, getCategoryBreakdown, getMonthlyBreakdown, getWeeklyBreakdown } from '../api/apiClient';

export function useCategoryBreakdown(params: AnalyticsParams = {}) {
  return useQuery({
    queryKey: ['analytics', 'categories', params],
    queryFn: () => getCategoryBreakdown(params),
  });
}

export function useMonthlyBreakdown(params: AnalyticsParams = {}) {
  return useQuery({
    queryKey: ['analytics', 'monthly', params],
    queryFn: () => getMonthlyBreakdown(params),
  });
}

export function useWeeklyBreakdown(params: AnalyticsParams = {}) {
  return useQuery({
    queryKey: ['analytics', 'weekly', params],
    queryFn: () => getWeeklyBreakdown(params),
  });
}
