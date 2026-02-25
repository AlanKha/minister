import AdmZip from 'adm-zip';
import fs from 'fs';
import path from 'path';
import { Hono } from 'hono';
import { cleanAllTransactions } from '../services/cleaningService.js';
import {
  loadCategoryRules,
  loadCleanTransactions,
  loadDefaultCategoryRules,
  loadOverrides,
  loadTransactions,
  readAccountData,
  saveCategoryRules,
  saveCleanTransactions,
  saveDeletedDefaults,
  saveOverrides,
  savePinnedTransactions,
  saveTransactions,
  writeAccountData,
} from '../store/jsonStore.js';

let serverRoot = '';

export function initSettingsRoutes(root: string): void {
  serverRoot = root;
}

const app = new Hono();

// GET /api/stats
app.get('/api/stats', (c) => {
  try {
    const transactions = loadTransactions();
    const cleanTxs = loadCleanTransactions();
    const rules = loadCategoryRules();
    const defaultRules = loadDefaultCategoryRules();
    const overrides = loadOverrides();
    const accounts = readAccountData();
    return c.json({
      transactions: transactions.length,
      cleanTransactions: cleanTxs.length,
      categoryRules: rules.length,
      defaultRules: defaultRules.length,
      overrides: Object.keys(overrides).length,
      accounts: accounts.accounts.length,
    });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/reset-categories
app.post('/api/settings/reset-categories', async (c) => {
  try {
    const defaultRules = loadDefaultCategoryRules();
    if (defaultRules.length === 0) {
      return c.json({ error: 'No default rules available' }, 400);
    }
    saveCategoryRules(defaultRules);
    saveDeletedDefaults(new Set());
    cleanAllTransactions();
    return c.json({
      success: true,
      count: defaultRules.length,
      message: `Reset to ${defaultRules.length} default rules`,
    });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/clear-categories
app.post('/api/settings/clear-categories', async (c) => {
  try {
    saveCategoryRules([]);
    saveDeletedDefaults(new Set());
    cleanAllTransactions();
    return c.json({ success: true, message: 'Cleared all category rules' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/recategorize
app.post('/api/settings/recategorize', async (c) => {
  try {
    cleanAllTransactions();
    return c.json({ success: true, message: 'Re-categorization complete' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/clear-overrides
app.post('/api/settings/clear-overrides', async (c) => {
  try {
    saveOverrides({});
    cleanAllTransactions();
    return c.json({ success: true, message: 'Cleared all category overrides' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/clear-pins
app.post('/api/settings/clear-pins', async (c) => {
  try {
    savePinnedTransactions(new Set());
    return c.json({ success: true, message: 'Cleared all pinned transactions' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/clear-transactions
app.post('/api/settings/clear-transactions', async (c) => {
  try {
    saveTransactions([]);
    saveCleanTransactions([]);
    saveOverrides({});
    return c.json({ success: true, message: 'Cleared all transaction data' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/settings/unlink-accounts
app.post('/api/settings/unlink-accounts', async (c) => {
  try {
    writeAccountData({ accounts: [] });
    return c.json({ success: true, message: 'Unlinked all accounts' });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// GET /api/backup
app.get('/api/backup', (c) => {
  try {
    const dataDir = path.join(serverRoot, 'data');
    if (!fs.existsSync(dataDir)) {
      return c.json({ error: 'Data directory not found' }, 404);
    }

    const zip = new AdmZip();
    const files = fs.readdirSync(dataDir);
    for (const file of files) {
      const filePath = path.join(dataDir, file);
      if (fs.statSync(filePath).isFile()) {
        zip.addLocalFile(filePath, 'data');
      }
    }

    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const filename = `minister-backup-${timestamp}.zip`;
    const buffer = zip.toBuffer();

    return new Response(buffer.buffer as ArrayBuffer, {
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': `attachment; filename="${filename}"`,
      },
    });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

// POST /api/backup/restore
app.post('/api/backup/restore', async (c) => {
  try {
    const formData = await c.req.parseBody();
    const file = formData['file'];

    let zipBuffer: Buffer;
    if (file instanceof File) {
      zipBuffer = Buffer.from(await file.arrayBuffer());
    } else if (typeof file === 'string' && file.length > 0) {
      zipBuffer = Buffer.from(file, 'binary');
    } else {
      return c.json({ error: 'No file uploaded' }, 400);
    }

    if (zipBuffer.length === 0) {
      return c.json({ error: 'No file uploaded' }, 400);
    }

    const dataDir = path.join(serverRoot, 'data');

    // Backup existing data before overwriting
    if (fs.existsSync(dataDir)) {
      const backupDir = path.join(serverRoot, `data-backup-${Date.now()}`);
      fs.renameSync(dataDir, backupDir);
    }
    fs.mkdirSync(dataDir, { recursive: true });

    const zip = new AdmZip(zipBuffer);
    const entries = zip.getEntries();
    let filesRestored = 0;

    for (const entry of entries) {
      if (!entry.isDirectory) {
        // Strip leading 'data/' prefix if present
        let entryName = entry.entryName;
        if (entryName.startsWith('data/') || entryName.startsWith('data\\')) {
          entryName = entryName.slice(5);
        }
        if (!entryName) continue;

        const outPath = path.join(dataDir, entryName);
        fs.mkdirSync(path.dirname(outPath), { recursive: true });
        fs.writeFileSync(outPath, entry.getData());
        filesRestored++;
      }
    }

    return c.json({
      success: true,
      message: 'Data restored successfully',
      filesRestored,
    });
  } catch (err) {
    return c.json({ error: String(err) }, 500);
  }
});

export default app;
