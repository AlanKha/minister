import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  createCategoryRule,
  deleteCategoryRule,
  getCategoryRules,
  importDefaultRules,
  updateCategoryRule,
} from '../api/apiClient';
import { CategoryRule } from '../models/categoryRule';

export function useCategoryRules() {
  return useQuery({
    queryKey: ['categoryRules'],
    queryFn: getCategoryRules,
  });
}

export function useCreateCategoryRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (rule: Omit<CategoryRule, 'id'>) => createCategoryRule(rule),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categoryRules'] }),
  });
}

export function useUpdateCategoryRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, rule }: { id: string; rule: Partial<Omit<CategoryRule, 'id'>> }) =>
      updateCategoryRule(id, rule),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categoryRules'] }),
  });
}

export function useDeleteCategoryRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => deleteCategoryRule(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categoryRules'] }),
  });
}

export function useImportDefaultRules() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: importDefaultRules,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['categoryRules'] });
      qc.invalidateQueries({ queryKey: ['transactions'] });
    },
  });
}
