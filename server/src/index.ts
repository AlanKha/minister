import { serve } from '@hono/node-server';
import { serveStatic } from '@hono/node-server/serve-static';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import path from 'path';
import { fileURLToPath } from 'url';
import { stripeEnv } from './config.js';
import { initStore } from './store/jsonStore.js';
import { initSettingsRoutes } from './routes/settings.js';

import accountsRouter from './routes/accounts.js';
import analyticsRouter from './routes/analytics.js';
import balancesRouter from './routes/balances.js';
import categoriesRouter from './routes/categories.js';
import settingsRouter from './routes/settings.js';
import syncRouter from './routes/sync.js';
import transactionsRouter from './routes/transactions.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const serverRoot = process.cwd();

initStore(serverRoot);
initSettingsRoutes(serverRoot);

const app = new Hono();

app.use('*', logger());
app.use(
  '*',
  cors({
    origin: '*',
    allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
  }),
);

// Mount all API routes
app.route('/', accountsRouter);
app.route('/', transactionsRouter);
app.route('/', syncRouter);
app.route('/', analyticsRouter);
app.route('/', balancesRouter);
app.route('/', categoriesRouter);
app.route('/', settingsRouter);

// Serve static files from public/
app.use(
  '*',
  serveStatic({
    root: path.relative(process.cwd(), path.join(serverRoot, 'public')),
  }),
);

serve({ fetch: app.fetch, port: 3000 }, () => {
  console.log(`Stripe mode: ${stripeEnv}`);
  console.log('Server running at http://localhost:3000');
});
