import { Hono } from 'hono';
import { cleanAllTransactions } from '../services/cleaningService.js';
import {
  loadCategoryRules,
  loadCleanTransactions,
  loadDefaultCategoryRules,
  loadOverrides,
  saveCategoryRules,
  saveOverrides,
} from '../store/jsonStore.js';
import type { CategoryRule } from '../types.js';

const app = new Hono();

app.get('/api/categories', (c) => {
  return c.json(loadCategoryRules());
});

app.post('/api/categories', async (c) => {
  try {
    const body = await c.req.json<{
      pattern?: string;
      category?: string;
      caseSensitive?: boolean;
    }>();
    const { pattern, category, caseSensitive = false } = body;

    if (!pattern) return c.json({ error: 'Pattern is required' }, 400);
    if (!category) return c.json({ error: 'Category is required' }, 400);

    try {
      new RegExp(pattern, caseSensitive ? '' : 'i');
    } catch (e) {
      return c.json({ error: `Invalid regex pattern: ${e}` }, 400);
    }

    const rules = loadCategoryRules();
    const newRule: CategoryRule = {
      id: String(Date.now()),
      category,
      pattern,
      caseSensitive,
    };
    rules.push(newRule);
    saveCategoryRules(rules);

    return c.json(newRule);
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

app.get('/api/categories/should-import-defaults', (c) => {
  const rules = loadCategoryRules();
  return c.json({ shouldImport: rules.length === 0, count: rules.length });
});

app.post('/api/categories/import-defaults', async (c) => {
  try {
    const defaultRules = loadDefaultCategoryRules();
    if (defaultRules.length === 0) {
      return c.json({ error: 'No default rules available to import' }, 400);
    }
    saveCategoryRules(defaultRules);
    cleanAllTransactions();
    return c.json({
      success: true,
      imported: defaultRules.length,
      message: `Imported ${defaultRules.length} default rules`,
    });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

app.put('/api/categories/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json<{
      pattern?: string;
      category?: string;
      caseSensitive?: boolean;
    }>();

    const rules = loadCategoryRules();
    const index = rules.findIndex((r) => r.id === id);
    if (index === -1) return c.json({ error: 'Category rule not found' }, 404);

    const updatedRule: CategoryRule = {
      id,
      category: body.category ?? rules[index].category,
      pattern: body.pattern ?? rules[index].pattern,
      caseSensitive: body.caseSensitive ?? rules[index].caseSensitive,
    };
    rules[index] = updatedRule;
    saveCategoryRules(rules);
    cleanAllTransactions();

    return c.json(updatedRule);
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

app.delete('/api/categories/:id', (c) => {
  try {
    const id = c.req.param('id');
    const rules = loadCategoryRules();
    const initialLength = rules.length;
    const filtered = rules.filter((r) => r.id !== id);
    if (filtered.length === initialLength) {
      return c.json({ error: 'Category rule not found' }, 404);
    }
    saveCategoryRules(filtered);
    cleanAllTransactions();
    return c.json({ success: true });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

app.post('/api/transactions/:id/categorize', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json<{
      category?: string;
      createRule?: boolean;
      rulePattern?: string;
    }>();
    const { category, createRule = false, rulePattern } = body;

    if (!category) return c.json({ error: 'Category is required' }, 400);

    const overrides = loadOverrides();
    overrides[id] = category;
    saveOverrides(overrides);

    if (createRule && rulePattern) {
      try {
        new RegExp(rulePattern, 'i');
        const rules = loadCategoryRules();
        rules.push({
          id: String(Date.now()),
          category,
          pattern: rulePattern,
          caseSensitive: false,
        });
        saveCategoryRules(rules);
      } catch (e) {
        return c.json({ error: `Invalid regex pattern: ${e}` }, 400);
      }
    }

    cleanAllTransactions();
    return c.json({ success: true, category });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

app.get('/api/transactions/uncategorized', (c) => {
  const transactions = loadCleanTransactions();
  return c.json(transactions.filter((tx) => tx.category === 'Uncategorized'));
});

export default app;
