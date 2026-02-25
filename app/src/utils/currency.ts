export function formatCents(cents: number): string {
  const abs = Math.abs(cents);
  const dollars = (abs / 100).toFixed(2);
  const formatted = Number(dollars).toLocaleString('en-CA', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  return cents < 0 ? `-$${formatted}` : `$${formatted}`;
}

export function formatAmount(cents: number): string {
  return formatCents(cents);
}

export function isExpense(cents: number): boolean {
  return cents < 0;
}
