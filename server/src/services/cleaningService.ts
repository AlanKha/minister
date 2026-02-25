import type { CategoryRule, CleanTransaction, StoredTransaction } from '../types.js';
import {
  loadCategoryRules,
  loadCleanTransactions,
  loadDefaultCategoryRules,
  loadOverrides,
  loadPinnedTransactions,
  loadTransactions,
  saveCleanTransactions,
} from '../store/jsonStore.js';

const DROP_FIELDS = new Set([
  'object',
  'account',
  'livemode',
  'updated',
  'transaction_refresh',
  'transacted_at',
]);

function buildRules(): Array<{ regexp: RegExp; category: string }> {
  const userRules = loadCategoryRules();
  const defaultRules = loadDefaultCategoryRules();
  // User rules first (higher precedence)
  return [...userRules, ...defaultRules].map((r: CategoryRule) => ({
    regexp: new RegExp(r.pattern, r.caseSensitive ? '' : 'i'),
    category: r.category,
  }));
}

export function categorize(
  description: string,
  transactionId: string,
  overrides: Record<string, string>,
): string {
  const override = overrides[transactionId];
  if (override) return override;

  const rules = buildRules();
  for (const rule of rules) {
    if (rule.regexp.test(description)) return rule.category;
  }
  return 'Uncategorized';
}

export function cleanTransaction(
  tx: StoredTransaction,
  overrides: Record<string, string>,
): CleanTransaction {
  const cleaned: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(tx)) {
    if (!DROP_FIELDS.has(key)) {
      cleaned[key] = value;
    }
  }

  // Normalize description
  if (typeof cleaned['description'] === 'string') {
    cleaned['description'] = cleaned['description'].replace(/\s+/g, ' ').trim();
  }

  const desc = (cleaned['description'] as string | undefined) ?? '';
  cleaned['category'] = categorize(desc, tx.id, overrides);

  const transactedAt = tx['transacted_at'];
  if (typeof transactedAt === 'number') {
    const d = new Date(transactedAt * 1000);
    cleaned['date'] = d.toISOString().slice(0, 10);
    cleaned['year'] = d.getUTCFullYear();
    cleaned['month'] = d.getUTCMonth() + 1;
  }

  const st = tx['status_transitions'];
  if (st && typeof st === 'object' && !Array.isArray(st)) {
    const normalized: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(st as Record<string, unknown>)) {
      if (typeof value === 'number') {
        normalized[key] = new Date(value * 1000).toISOString().slice(0, 10);
      } else {
        normalized[key] = value;
      }
    }
    cleaned['status_transitions'] = normalized;
  }

  return cleaned as CleanTransaction;
}

export function cleanAllTransactions(): CleanTransaction[] {
  const transactions = loadTransactions();
  const overrides = loadOverrides();
  const pinned = loadPinnedTransactions();

  // Load existing clean transactions to preserve categories for pinned ones
  const existingClean = new Map<string, CleanTransaction>();
  if (pinned.size > 0) {
    for (const tx of loadCleanTransactions()) {
      existingClean.set(tx.id, tx);
    }
  }

  const cleaned = transactions.map((tx) => {
    const result = cleanTransaction(tx, overrides);
    // If pinned, restore its existing category
    if (pinned.has(tx.id) && existingClean.has(tx.id)) {
      result.category = existingClean.get(tx.id)!.category;
    }
    return result;
  });

  saveCleanTransactions(cleaned);
  return cleaned;
}
