import { AccountData } from '../models/account';
import { AppStats, BalanceEntry, CategoryBreakdown, MonthlyBreakdown, WeeklyBreakdown } from '../models/analytics';
import { CategoryRule } from '../models/categoryRule';
import { CleanTransaction, TransactionFilters, TransactionPage } from '../models/transaction';

const BASE_URL = 'http://localhost:3000';

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const url = `${BASE_URL}${path}`;
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    ...options,
  });
  if (res.status >= 400) {
    let msg = `HTTP ${res.status}`;
    try {
      const body = await res.json();
      msg = body.error ?? body.message ?? msg;
    } catch {}
    throw new Error(msg);
  }
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

// ── Accounts ─────────────────────────────────────────────────────────────────

export async function getAccounts(): Promise<AccountData> {
  return request<AccountData>('/api/accounts');
}

// ── Transactions ──────────────────────────────────────────────────────────────

export async function getTransactions(filters: Partial<TransactionFilters> = {}): Promise<TransactionPage> {
  const params = new URLSearchParams();
  if (filters.account) params.set('account', filters.account);
  if (filters.category) params.set('category', filters.category);
  if (filters.startDate) params.set('startDate', filters.startDate);
  if (filters.endDate) params.set('endDate', filters.endDate);
  if (filters.search) params.set('search', filters.search);
  if (filters.sort) params.set('sort', filters.sort);
  if (filters.page != null) params.set('page', String(filters.page));
  const qs = params.toString();
  return request<TransactionPage>(`/api/transactions${qs ? `?${qs}` : ''}`);
}

export async function getUncategorizedTransactions(): Promise<CleanTransaction[]> {
  return request<CleanTransaction[]>('/api/transactions/uncategorized');
}

export async function updateTransaction(
  id: string,
  patch: { category?: string; pinned?: boolean },
): Promise<void> {
  return request<void>(`/api/transactions/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(patch),
  });
}

export async function categorizeTransaction(
  id: string,
  category: string,
  createRule: boolean,
): Promise<void> {
  return request<void>(`/api/transactions/${id}/categorize`, {
    method: 'POST',
    body: JSON.stringify({ category, createRule }),
  });
}

// ── Analytics ─────────────────────────────────────────────────────────────────

export interface AnalyticsParams {
  startDate?: string;
  endDate?: string;
  account?: string;
}

export async function getCategoryBreakdown(params: AnalyticsParams = {}): Promise<CategoryBreakdown[]> {
  const qs = new URLSearchParams(params as Record<string, string>).toString();
  return request<CategoryBreakdown[]>(`/api/analytics/categories${qs ? `?${qs}` : ''}`);
}

export async function getMonthlyBreakdown(params: AnalyticsParams = {}): Promise<MonthlyBreakdown[]> {
  const qs = new URLSearchParams(params as Record<string, string>).toString();
  return request<MonthlyBreakdown[]>(`/api/analytics/monthly${qs ? `?${qs}` : ''}`);
}

export async function getWeeklyBreakdown(params: AnalyticsParams = {}): Promise<WeeklyBreakdown[]> {
  const qs = new URLSearchParams(params as Record<string, string>).toString();
  return request<WeeklyBreakdown[]>(`/api/analytics/weekly${qs ? `?${qs}` : ''}`);
}

// ── Category Rules ────────────────────────────────────────────────────────────

export async function getCategoryRules(): Promise<CategoryRule[]> {
  return request<CategoryRule[]>('/api/categories');
}

export async function createCategoryRule(rule: Omit<CategoryRule, 'id'>): Promise<CategoryRule> {
  return request<CategoryRule>('/api/categories', {
    method: 'POST',
    body: JSON.stringify(rule),
  });
}

export async function updateCategoryRule(id: string, rule: Partial<Omit<CategoryRule, 'id'>>): Promise<CategoryRule> {
  return request<CategoryRule>(`/api/categories/${id}`, {
    method: 'PUT',
    body: JSON.stringify(rule),
  });
}

export async function deleteCategoryRule(id: string): Promise<void> {
  return request<void>(`/api/categories/${id}`, { method: 'DELETE' });
}

export async function importDefaultRules(): Promise<void> {
  return request<void>('/api/categories/import-defaults', { method: 'POST' });
}

export async function shouldImportDefaults(): Promise<boolean> {
  const res = await request<{ shouldImport: boolean }>('/api/categories/should-import-defaults');
  return res.shouldImport;
}

// ── Sync ──────────────────────────────────────────────────────────────────────

export async function syncAll(): Promise<void> {
  return request<void>('/api/sync', { method: 'POST' });
}

export async function syncFetch(): Promise<void> {
  return request<void>('/api/sync/fetch', { method: 'POST' });
}

export async function syncClean(): Promise<void> {
  return request<void>('/api/sync/clean', { method: 'POST' });
}

// ── Balances ──────────────────────────────────────────────────────────────────

export async function getBalances(): Promise<BalanceEntry[]> {
  return request<BalanceEntry[]>('/api/balances');
}

export async function refreshBalances(accountIds?: string[]): Promise<void> {
  return request<void>('/api/balances/refresh', {
    method: 'POST',
    body: JSON.stringify({ accountIds }),
  });
}

// ── Settings / Admin ──────────────────────────────────────────────────────────

export async function getStats(): Promise<AppStats> {
  return request<AppStats>('/api/stats');
}

export async function resetCategoryRules(): Promise<void> {
  return request<void>('/api/settings/reset-categories', { method: 'POST' });
}

export async function clearCategoryRules(): Promise<void> {
  return request<void>('/api/settings/clear-categories', { method: 'POST' });
}

export async function recategorize(): Promise<void> {
  return request<void>('/api/settings/recategorize', { method: 'POST' });
}

export async function clearOverrides(): Promise<void> {
  return request<void>('/api/settings/clear-overrides', { method: 'POST' });
}

export async function clearPins(): Promise<void> {
  return request<void>('/api/settings/clear-pins', { method: 'POST' });
}

export async function clearTransactions(): Promise<void> {
  return request<void>('/api/settings/clear-transactions', { method: 'POST' });
}

export async function unlinkAccounts(): Promise<void> {
  return request<void>('/api/settings/unlink-accounts', { method: 'POST' });
}

export function getBackupUrl(): string {
  return `${BASE_URL}/api/backup`;
}

export async function restoreBackup(fileUri: string): Promise<void> {
  const formData = new FormData();
  formData.append('file', {
    uri: fileUri,
    name: 'backup.zip',
    type: 'application/zip',
  } as unknown as Blob);
  return request<void>('/api/backup/restore', {
    method: 'POST',
    headers: { 'Content-Type': 'multipart/form-data' },
    body: formData as unknown as BodyInit,
  });
}
