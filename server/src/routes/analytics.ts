import { Hono } from 'hono';
import {
  getCategoryBreakdown,
  getMonthlyBreakdown,
  getWeeklyBreakdown,
} from '../services/analyticsService.js';
import type { AnalyticsFilters } from '../types.js';

const app = new Hono();

app.get('/api/analytics/categories', (c) => {
  const filters: AnalyticsFilters = {
    startDate: c.req.query('startDate'),
    endDate: c.req.query('endDate'),
    account: c.req.query('account'),
    category: c.req.query('category'),
  };
  return c.json(getCategoryBreakdown(filters));
});

app.get('/api/analytics/monthly', (c) => {
  const filters: AnalyticsFilters = {
    startDate: c.req.query('startDate'),
    endDate: c.req.query('endDate'),
    account: c.req.query('account'),
    category: c.req.query('category'),
  };
  return c.json(getMonthlyBreakdown(filters));
});

app.get('/api/analytics/weekly', (c) => {
  const filters: AnalyticsFilters = {
    startDate: c.req.query('startDate'),
    endDate: c.req.query('endDate'),
    account: c.req.query('account'),
    category: c.req.query('category'),
  };
  return c.json(getWeeklyBreakdown(filters));
});

export default app;
