import { Hono } from 'hono';
import { stripePublishableKey } from '../config.js';
import { stripe } from '../stripe.js';
import { readAccountData, writeAccountData } from '../store/jsonStore.js';
import type { LinkedAccount } from '../types.js';

const app = new Hono();

app.get('/api/accounts', (c) => {
  const data = readAccountData();
  return c.json(data.accounts);
});

app.get('/config', (c) => {
  return c.json({ publishableKey: stripePublishableKey });
});

app.post('/create-session', async (c) => {
  try {
    const data = readAccountData();

    if (!data.customer_id) {
      const customer = await stripe.customers.create();
      data.customer_id = customer.id;
      writeAccountData(data);
    }

    const session = await stripe.financialConnections.sessions.create({
      account_holder: {
        type: 'customer',
        customer: data.customer_id,
      },
      permissions: ['transactions', 'balances'],
      prefetch: ['transactions'],
    });

    return c.json({ clientSecret: session.client_secret });
  } catch (err: unknown) {
    const stripeErr = err as { type?: string; message?: string };
    if (stripeErr?.type === 'StripeAuthenticationError') {
      return c.json({ error: 'Invalid Stripe API key' }, 500);
    }
    return c.json({ error: String(err) }, 500);
  }
});

app.post('/save-account', async (c) => {
  try {
    const body = await c.req.json<{
      accountId?: string;
      institution?: string;
      displayName?: string;
      last4?: string;
    }>();
    const accountId = body.accountId;

    if (!accountId) {
      return c.json({ error: 'accountId is required' }, 400);
    }

    try {
      await stripe.financialConnections.accounts.subscribe(accountId, {
        features: ['transactions'],
      });
    } catch (err) {
      console.log('Subscribe skipped (account may be inactive):', err);
    }

    const data = readAccountData();
    if (!data.accounts.some((a) => a.id === accountId)) {
      const acct: LinkedAccount = {
        id: accountId,
        institution: body.institution,
        display_name: body.displayName,
        last4: body.last4,
        linked_at: new Date().toISOString(),
      };
      data.accounts.push(acct);
      writeAccountData(data);
    }

    return c.json({ success: true, accountId });
  } catch (err: unknown) {
    const stripeErr = err as { type?: string; message?: string };
    if (stripeErr?.type === 'StripeInvalidRequestError') {
      return c.json({ error: `Stripe error: ${stripeErr.message}` }, 500);
    }
    return c.json({ error: String(err) }, 500);
  }
});

export default app;
