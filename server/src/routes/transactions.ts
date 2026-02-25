import { Hono } from 'hono';
import {
  loadCleanTransactions,
  loadOverrides,
  loadPinnedTransactions,
  saveCleanTransactions,
  saveOverrides,
  savePinnedTransactions,
} from '../store/jsonStore.js';

const app = new Hono();

app.get('/api/transactions', (c) => {
  let transactions = loadCleanTransactions();

  const account = c.req.query('account');
  const category = c.req.query('category');
  const startDate = c.req.query('startDate');
  const endDate = c.req.query('endDate');
  const search = c.req.query('search');
  const sort = c.req.query('sort') ?? 'date_desc';
  const page = parseInt(c.req.query('page') ?? '1', 10) || 1;
  const limit = parseInt(c.req.query('limit') ?? '50', 10) || 50;

  if (account) {
    const acct = account.toLowerCase();
    transactions = transactions.filter((tx) =>
      (tx.account_label ?? '').toLowerCase().includes(acct),
    );
  }
  if (category) {
    const cat = category.toLowerCase();
    transactions = transactions.filter((tx) => tx.category.toLowerCase() === cat);
  }
  if (startDate) {
    transactions = transactions.filter((tx) => tx.date >= startDate);
  }
  if (endDate) {
    transactions = transactions.filter((tx) => tx.date <= endDate);
  }
  if (search) {
    const q = search.toLowerCase();
    transactions = transactions.filter((tx) =>
      (tx.description ?? '').toLowerCase().includes(q),
    );
  }

  switch (sort) {
    case 'date_asc':
      transactions.sort((a, b) => a.date.localeCompare(b.date));
      break;
    case 'amount_asc':
      transactions.sort((a, b) => a.amount - b.amount);
      break;
    case 'amount_desc':
      transactions.sort((a, b) => b.amount - a.amount);
      break;
    default:
      transactions.sort((a, b) => b.date.localeCompare(a.date));
  }

  const total = transactions.length;
  const start = (page - 1) * limit;
  const paginated = transactions.slice(Math.min(start, total), Math.min(start + limit, total));

  return c.json({
    data: paginated,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
});

app.get('/api/transactions/pinned', (c) => {
  const pinned = loadPinnedTransactions();
  return c.json([...pinned]);
});

app.get('/api/transactions/uncategorized', (c) => {
  const transactions = loadCleanTransactions();
  return c.json(transactions.filter((tx) => tx.category === 'Uncategorized'));
});

app.patch('/api/transactions/:id', async (c) => {
  const id = c.req.param('id');
  const body = await c.req.json<{ category?: string; pinned?: boolean }>();
  const { category, pinned } = body;

  if (category === undefined && pinned === undefined) {
    return c.json({ error: 'category or pinned is required' }, 400);
  }

  const transactions = loadCleanTransactions();
  const txIndex = transactions.findIndex((t) => t.id === id);
  if (txIndex === -1) {
    return c.json({ error: 'Transaction not found' }, 404);
  }

  if (pinned !== undefined) {
    const pinnedSet = loadPinnedTransactions();
    if (pinned) {
      pinnedSet.add(id);
    } else {
      pinnedSet.delete(id);
    }
    savePinnedTransactions(pinnedSet);
  }

  if (category !== undefined && category !== '') {
    const overrides = loadOverrides();
    if (category === 'Uncategorized') {
      delete overrides[id];
    } else {
      overrides[id] = category;
    }
    saveOverrides(overrides);
    transactions[txIndex].category = category;
    saveCleanTransactions(transactions);
  }

  return c.json({
    success: true,
    transaction: transactions[txIndex],
    pinned: loadPinnedTransactions().has(id),
  });
});

export default app;
