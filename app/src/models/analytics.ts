export interface CategoryBreakdown {
  category: string;
  count: number;
  totalCents: number;
  total: string;
}

export interface MonthlyBreakdown {
  month: string;
  count: number;
  totalCents: number;
  total: string;
}

export interface WeeklyBreakdown {
  weekStart: string;
  count: number;
  totalCents: number;
  total: string;
}

export interface BalanceEntry {
  accountId: string;
  accountLabel: string;
  balanceCents: number;
  availableCents?: number;
  currency: string;
  asOf: string;
}

export interface AppStats {
  transactionCount: number;
  accountCount: number;
  categoryRuleCount: number;
  uncategorizedCount: number;
  pinnedCount: number;
}
