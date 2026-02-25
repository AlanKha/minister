export interface LinkedAccount {
  id: string;
  institution?: string;
  displayName?: string;
  last4?: string;
  linkedAt: string;
  label: string;
}

export interface AccountData {
  customerId?: string;
  accounts: LinkedAccount[];
}
