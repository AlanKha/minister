import fs from 'fs';
import path from 'path';
import type { AccountData, CategoryRule, CleanTransaction, LinkedAccount, StoredTransaction } from '../types.js';

let dataDir = '';
let serverRoot = '';

export function initStore(root: string): void {
  serverRoot = root;
  dataDir = path.join(root, 'data');
  fs.mkdirSync(dataDir, { recursive: true });
}

function accountFile(): string { return path.join(dataDir, 'linked_account.json'); }
function txFile(): string { return path.join(dataDir, 'transactions.json'); }
function cleanFile(): string { return path.join(dataDir, 'transactions_clean.json'); }
function overridesFile(): string { return path.join(dataDir, 'category_overrides.json'); }
function categoryRulesFile(): string { return path.join(dataDir, 'category_rules.json'); }
function balancesFile(): string { return path.join(dataDir, 'balances.json'); }
function pinnedTransactionsFile(): string { return path.join(dataDir, 'pinned_transactions.json'); }
function deletedDefaultsFile(): string { return path.join(dataDir, 'deleted_defaults.json'); }
function defaultCategoryRulesFile(): string { return path.join(serverRoot, 'default_category_rules.json'); }
function exampleDefaultCategoryRulesFile(): string { return path.join(serverRoot, 'example_default_category_rules.json'); }

function readJson<T>(file: string, fallback: T): T {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf-8')) as T;
  } catch {
    return fallback;
  }
}

function writeJson(file: string, data: unknown): void {
  fs.mkdirSync(dataDir, { recursive: true });
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
}

export function accountLabel(acct: LinkedAccount): string {
  return [acct.institution, acct.display_name, acct.last4 ? `****${acct.last4}` : undefined]
    .filter((s): s is string => typeof s === 'string' && s.length > 0)
    .join(' ');
}

// ── Account data ──────────────────────────────────────────────────────────────

export function readAccountData(): AccountData {
  return readJson<AccountData>(accountFile(), { accounts: [] });
}

export function writeAccountData(data: AccountData): void {
  writeJson(accountFile(), data);
}

// ── Transactions ──────────────────────────────────────────────────────────────

export function loadTransactions(): StoredTransaction[] {
  return readJson<StoredTransaction[]>(txFile(), []);
}

export function saveTransactions(txs: StoredTransaction[]): void {
  writeJson(txFile(), txs);
}

export function loadCleanTransactions(): CleanTransaction[] {
  return readJson<CleanTransaction[]>(cleanFile(), []);
}

export function saveCleanTransactions(txs: CleanTransaction[]): void {
  writeJson(cleanFile(), txs);
}

// ── Overrides ─────────────────────────────────────────────────────────────────

export function loadOverrides(): Record<string, string> {
  return readJson<Record<string, string>>(overridesFile(), {});
}

export function saveOverrides(overrides: Record<string, string>): void {
  writeJson(overridesFile(), overrides);
}

// ── Pinned transactions ───────────────────────────────────────────────────────

export function loadPinnedTransactions(): Set<string> {
  const arr = readJson<string[]>(pinnedTransactionsFile(), []);
  return new Set(arr);
}

export function savePinnedTransactions(pinned: Set<string>): void {
  writeJson(pinnedTransactionsFile(), [...pinned]);
}

// ── Category rules ────────────────────────────────────────────────────────────

export function loadCategoryRules(): CategoryRule[] {
  return readJson<CategoryRule[]>(categoryRulesFile(), []);
}

export function saveCategoryRules(rules: CategoryRule[]): void {
  writeJson(categoryRulesFile(), rules);
}

// ── Balances ──────────────────────────────────────────────────────────────────

export function loadBalances(): Record<string, unknown> {
  return readJson<Record<string, unknown>>(balancesFile(), {});
}

export function saveBalances(balances: Record<string, unknown>): void {
  writeJson(balancesFile(), balances);
}

// ── Deleted defaults ──────────────────────────────────────────────────────────

export function loadDeletedDefaults(): Set<string> {
  const arr = readJson<string[]>(deletedDefaultsFile(), []);
  return new Set(arr);
}

export function saveDeletedDefaults(deleted: Set<string>): void {
  writeJson(deletedDefaultsFile(), [...deleted]);
}

// ── Default category rules ────────────────────────────────────────────────────

export function loadDefaultCategoryRules(): CategoryRule[] {
  const defaultFile = defaultCategoryRulesFile();
  if (!fs.existsSync(defaultFile)) {
    const exampleFile = exampleDefaultCategoryRulesFile();
    if (fs.existsSync(exampleFile)) {
      fs.writeFileSync(defaultFile, fs.readFileSync(exampleFile, 'utf-8'));
    } else {
      return [];
    }
  }
  return readJson<CategoryRule[]>(defaultFile, []);
}
