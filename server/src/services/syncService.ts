import { stripe } from '../stripe.js';
import { accountLabel, loadTransactions, readAccountData, saveTransactions } from '../store/jsonStore.js';
import type { StoredTransaction, SyncResult } from '../types.js';

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function refreshAccount(accountId: string): Promise<void> {
  await stripe.financialConnections.accounts.refresh(accountId, {
    features: ['transactions'],
  });

  const maxAttempts = 30;
  for (let i = 0; i < maxAttempts; i++) {
    const account = await stripe.financialConnections.accounts.retrieve(accountId);
    const refresh = account.transaction_refresh as { status?: string } | null;
    const status = refresh?.status;

    if (status === 'succeeded') return;
    if (status === 'failed') throw new Error('Transaction refresh failed');
    if (i === maxAttempts - 1) throw new Error('Refresh timed out after 60s');

    await sleep(2000);
  }
}

async function fetchTransactions(accountId: string): Promise<Record<string, unknown>[]> {
  const txs: Record<string, unknown>[] = [];
  let startingAfter: string | undefined;

  while (true) {
    const page = await stripe.financialConnections.transactions.list({
      account: accountId,
      limit: 100,
      starting_after: startingAfter,
    });

    for (const tx of page.data) {
      txs.push(tx as unknown as Record<string, unknown>);
    }

    if (!page.has_more) break;
    startingAfter = page.data[page.data.length - 1].id;
  }

  return txs;
}

export async function syncFromStripe(accountIds?: string[]): Promise<SyncResult> {
  const accountData = readAccountData();
  let accounts = accountData.accounts;

  if (accounts.length === 0) {
    return { newCount: 0, totalCount: 0, errors: ['No linked accounts found'] };
  }

  if (accountIds && accountIds.length > 0) {
    const idSet = new Set(accountIds);
    accounts = accounts.filter((a) => idSet.has(a.id));
    if (accounts.length === 0) {
      return { newCount: 0, totalCount: 0, errors: ['No matching accounts found'] };
    }
  }

  const existing = loadTransactions();
  const knownIds = new Set(existing.map((tx) => tx.id));
  const newTxs: StoredTransaction[] = [];
  const errors: string[] = [];

  for (const acct of accounts) {
    const label = accountLabel(acct);

    try {
      await refreshAccount(acct.id);
    } catch (err) {
      errors.push(`[${label}] Refresh failed: ${err}`);
      continue;
    }

    try {
      const txs = await fetchTransactions(acct.id);
      for (const tx of txs) {
        const id = tx['id'] as string;
        if (!knownIds.has(id)) {
          tx['account_id'] = acct.id;
          tx['account_label'] = label;
          newTxs.push(tx as StoredTransaction);
          knownIds.add(id);
        }
      }
    } catch (err) {
      errors.push(`[${label}] Fetch failed: ${err}`);
      continue;
    }
  }

  const all = [...existing, ...newTxs];
  all.sort((a, b) => (b.transacted_at ?? 0) - (a.transacted_at ?? 0));
  saveTransactions(all);

  return { newCount: newTxs.length, totalCount: all.length, errors };
}
