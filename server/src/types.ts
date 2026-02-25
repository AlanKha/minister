export interface LinkedAccount {
  id: string;
  institution?: string;
  display_name?: string;
  last4?: string;
  linked_at: string;
}

export interface AccountData {
  customer_id?: string;
  accounts: LinkedAccount[];
}

export interface StoredTransaction {
  id: string;
  transacted_at: number;
  amount: number;
  status: string;
  description?: string;
  account_id: string;
  account_label: string;
  [key: string]: unknown;
}

export interface CleanTransaction {
  id: string;
  amount: number;
  description?: string;
  status?: string;
  category: string;
  date: string;
  year: number;
  month: number;
  account_id?: string;
  account_label?: string;
  [key: string]: unknown;
}

export interface CategoryRule {
  id: string;
  category: string;
  pattern: string;
  caseSensitive: boolean;
}

export interface SyncResult {
  newCount: number;
  totalCount: number;
  errors: string[];
}

export interface AnalyticsFilters {
  startDate?: string;
  endDate?: string;
  account?: string;
  category?: string;
}
