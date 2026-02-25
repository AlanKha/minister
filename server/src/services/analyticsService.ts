import { loadCleanTransactions } from '../store/jsonStore.js';
import type { AnalyticsFilters, CleanTransaction } from '../types.js';

function applyFilters(transactions: CleanTransaction[], filters: AnalyticsFilters): CleanTransaction[] {
  // Only expenses (negative amounts), exclude Transfer category
  let filtered = transactions.filter((tx) => tx.amount < 0 && tx.category !== 'Transfer');

  if (filters.startDate) {
    filtered = filtered.filter((tx) => tx.date >= filters.startDate!);
  }
  if (filters.endDate) {
    filtered = filtered.filter((tx) => tx.date <= filters.endDate!);
  }
  if (filters.account) {
    const acct = filters.account.toLowerCase();
    filtered = filtered.filter((tx) => (tx.account_label ?? '').toLowerCase().includes(acct));
  }
  if (filters.category) {
    const cat = filters.category.toLowerCase();
    filtered = filtered.filter((tx) => tx.category.toLowerCase() === cat);
  }

  return filtered;
}

export function getCategoryBreakdown(filters: AnalyticsFilters): object[] {
  const transactions = applyFilters(loadCleanTransactions(), filters);

  const categories = new Map<string, { count: number; total_cents: number }>();
  for (const tx of transactions) {
    const cat = tx.category;
    if (!categories.has(cat)) categories.set(cat, { count: 0, total_cents: 0 });
    const entry = categories.get(cat)!;
    entry.count += 1;
    entry.total_cents += tx.amount;
  }

  const entries = [...categories.entries()].sort(
    (a, b) => a[1].total_cents - b[1].total_cents,
  );

  return entries.map(([category, { count, total_cents }]) => ({
    category,
    count,
    total_cents,
    total: `$${(Math.abs(total_cents) / 100).toFixed(2)}`,
  }));
}

export function getMonthlyBreakdown(filters: AnalyticsFilters): object[] {
  const transactions = applyFilters(loadCleanTransactions(), filters);

  const months = new Map<string, { count: number; total_cents: number }>();
  for (const tx of transactions) {
    const key = `${tx.year}-${String(tx.month).padStart(2, '0')}`;
    if (!months.has(key)) months.set(key, { count: 0, total_cents: 0 });
    const entry = months.get(key)!;
    entry.count += 1;
    entry.total_cents += tx.amount;
  }

  const entries = [...months.entries()].sort((a, b) => a[0].localeCompare(b[0]));

  return entries.map(([month, { count, total_cents }]) => ({
    month,
    count,
    total_cents,
    total: `$${(Math.abs(total_cents) / 100).toFixed(2)}`,
  }));
}

function getWeekStart(dateStr: string): string {
  const d = new Date(`${dateStr}T00:00:00Z`);
  // JS: Sunday=0, Monday=1, ... Saturday=6
  const day = d.getDay(); // Use getDay() directly (not % 7)
  const weekStart = new Date(d);
  weekStart.setUTCDate(d.getUTCDate() - day);
  return weekStart.toISOString().slice(0, 10);
}

export function getWeeklyBreakdown(filters: AnalyticsFilters): object[] {
  const transactions = applyFilters(loadCleanTransactions(), filters);

  const weeks = new Map<string, { count: number; total_cents: number }>();
  for (const tx of transactions) {
    if (!tx.date) continue;
    const week = getWeekStart(tx.date);
    if (!weeks.has(week)) weeks.set(week, { count: 0, total_cents: 0 });
    const entry = weeks.get(week)!;
    entry.count += 1;
    entry.total_cents += tx.amount;
  }

  const entries = [...weeks.entries()].sort((a, b) => a[0].localeCompare(b[0]));

  return entries.map(([week_start, { count, total_cents }]) => ({
    week_start,
    count,
    total_cents,
    total: `$${(Math.abs(total_cents) / 100).toFixed(2)}`,
  }));
}
