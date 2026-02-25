import { Hono } from 'hono';
import { stripe } from '../stripe.js';
import {
  loadBalances,
  readAccountData,
  saveBalances,
} from '../store/jsonStore.js';

const app = new Hono();

app.get('/api/balances', (c) => {
  const balances = loadBalances();
  const { accounts } = readAccountData();

  const result = accounts.map((acct) => {
    const cached = balances[acct.id] as Record<string, unknown> | undefined;
    return {
      account_id: acct.id,
      institution: acct.institution,
      display_name: acct.display_name,
      last4: acct.last4,
      balance: cached?.['balance'],
      balance_refresh: cached?.['balance_refresh'],
      last_refreshed: cached?.['last_refreshed'],
      error: cached?.['error'],
    };
  });

  return c.json(result);
});

app.post('/api/balances/refresh', async (c) => {
  try {
    let requestedIds: string[] | undefined;
    try {
      const body = await c.req.json<{ accountIds?: string[] }>();
      requestedIds = body.accountIds;
    } catch {
      // No body
    }

    const accountData = readAccountData();
    const toRefresh =
      requestedIds && requestedIds.length > 0
        ? accountData.accounts.filter((a) => requestedIds!.includes(a.id))
        : accountData.accounts;

    if (toRefresh.length === 0) {
      return c.json({ error: 'No accounts to refresh' });
    }

    const balances = loadBalances() as Record<string, Record<string, unknown>>;
    const results: Record<string, unknown>[] = [];

    for (const acct of toRefresh) {
      try {
        await stripe.financialConnections.accounts.refresh(acct.id, {
          features: ['balance'],
        });

        let accountData: Record<string, unknown> | undefined;
        for (let i = 0; i < 30; i++) {
          await new Promise((resolve) => setTimeout(resolve, 2000));
          const retrieved = await stripe.financialConnections.accounts.retrieve(acct.id);
          accountData = retrieved as unknown as Record<string, unknown>;

          const refreshStatus = accountData['balance_refresh'] as { status?: string } | null;
          if (!refreshStatus) break;
          const status = refreshStatus.status;
          if (status === 'succeeded' || status === 'failed') break;
        }

        if (accountData) {
          const entry: Record<string, unknown> = {
            balance: accountData['balance'],
            balance_refresh: accountData['balance_refresh'],
            last_refreshed: new Date().toISOString(),
          };
          balances[acct.id] = entry;
          results.push({
            account_id: acct.id,
            institution: acct.institution,
            display_name: acct.display_name,
            last4: acct.last4,
            ...entry,
          });
        }
      } catch (err: unknown) {
        const stripeErr = err as { message?: string };
        const entry: Record<string, unknown> = {
          error: stripeErr?.message ?? String(err),
          last_refreshed: new Date().toISOString(),
        };
        balances[acct.id] = entry;
        results.push({
          account_id: acct.id,
          institution: acct.institution,
          display_name: acct.display_name,
          last4: acct.last4,
          ...entry,
        });
      }
    }

    saveBalances(balances);
    return c.json(results);
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

export default app;
