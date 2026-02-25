import { Hono } from 'hono';
import { cleanAllTransactions } from '../services/cleaningService.js';
import { syncFromStripe } from '../services/syncService.js';

const app = new Hono();

app.post('/api/sync', async (c) => {
  try {
    let accountIds: string[] | undefined;
    try {
      const body = await c.req.json<{ accountIds?: string[] }>();
      accountIds = body.accountIds;
    } catch {
      // No body or invalid JSON — that's fine
    }

    const fetchResult = await syncFromStripe(accountIds);
    const cleaned = cleanAllTransactions();

    return c.json({
      fetch: fetchResult,
      clean: { count: cleaned.length },
    });
  } catch (err) {
    console.error('Sync error:', err);
    return c.json({ error: String(err) }, 500);
  }
});

app.post('/api/sync/fetch', async (c) => {
  try {
    let accountIds: string[] | undefined;
    try {
      const body = await c.req.json<{ accountIds?: string[] }>();
      accountIds = body.accountIds;
    } catch {
      // No body
    }

    const result = await syncFromStripe(accountIds);
    return c.json(result);
  } catch (err) {
    console.error('Fetch error:', err);
    return c.json({ error: String(err) }, 500);
  }
});

app.post('/api/sync/clean', async (c) => {
  try {
    const cleaned = cleanAllTransactions();
    return c.json({ count: cleaned.length });
  } catch (err) {
    console.error('Clean error:', err);
    return c.json({ error: String(err) }, 500);
  }
});

export default app;
