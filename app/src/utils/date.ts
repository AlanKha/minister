export function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00');
  return date.toLocaleDateString('en-CA', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

export function formatDateShort(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00');
  return date.toLocaleDateString('en-CA', { month: 'short', day: 'numeric' });
}

export function formatMonth(monthStr: string): string {
  // expects YYYY-MM
  const [year, month] = monthStr.split('-');
  const date = new Date(Number(year), Number(month) - 1, 1);
  return date.toLocaleDateString('en-CA', { month: 'short', year: 'numeric' });
}

export function formatWeek(weekStart: string): string {
  const date = new Date(weekStart + 'T00:00:00');
  return date.toLocaleDateString('en-CA', { month: 'short', day: 'numeric' });
}

export function todayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

export function monthStartISO(monthsAgo = 0): string {
  const d = new Date();
  d.setMonth(d.getMonth() - monthsAgo);
  d.setDate(1);
  return d.toISOString().slice(0, 10);
}
