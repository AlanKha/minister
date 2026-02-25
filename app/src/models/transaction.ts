export interface CleanTransaction {
  id: string;
  amount: number;
  description: string;
  status: string;
  category: string;
  date: string;
  year: number;
  month: number;
  account: string;
  accountLabel: string;
  pinned?: boolean;
}

export interface TransactionPage {
  data: CleanTransaction[];
  page: number;
  totalPages: number;
  total: number;
}

export interface TransactionFilters {
  account?: string;
  category?: string;
  startDate?: string;
  endDate?: string;
  search?: string;
  sort: string;
  page: number;
}
