export const AppColors = {
  // ── Backgrounds ────────────────────────────────────────
  background: '#09090D',
  surface: '#111116',
  surfaceContainer: '#18181F',
  surfaceHigh: '#1F1F28',

  // ── Sidebar ─────────────────────────────────────────────
  sidebarBg: '#07070A',
  sidebarHover: '#111116',
  sidebarActive: '#FF5C38',
  sidebarText: '#F2F2F8',
  sidebarTextMuted: 'rgba(242,242,248,0.35)',

  // ── Accent (electric coral) ──────────────────────────────
  accent: '#FF5C38',
  accentLight: '#FF7A5C',
  accentMuted: '#CC4930',
  accentSurface: 'rgba(255,92,56,0.10)',

  // ── Text ─────────────────────────────────────────────────
  textPrimary: '#F2F2F8',
  textSecondary: '#8080A0',
  textTertiary: '#6E6E90',

  // ── Semantic ─────────────────────────────────────────────
  positive: '#00D4A0',
  positiveLight: 'rgba(0,212,160,0.12)',
  negative: '#FF4A6B',
  negativeLight: 'rgba(255,74,107,0.12)',
  info: '#5B8EF0',
  warning: '#F0A030',

  // ── Borders ──────────────────────────────────────────────
  border: 'rgba(255,255,255,0.07)',
  borderSubtle: 'rgba(255,255,255,0.04)',

  // ── Category colors (vibrant for dark backgrounds) ───────
  categoryColors: {
    Dining: '#FF7B6B',
    Grocery: '#4DD98A',
    Shopping: '#C882F0',
    Superstore: '#60A8FF',
    Transit: '#FFCC5C',
    Gas: '#D4A06A',
    Rent: '#E08855',
    Utilities: '#5BBCD6',
    Transfer: '#78CCA4',
    Fee: '#A0A2B4',
    Loan: '#D49A7A',
    Entertainment: '#E870BE',
    Travel: '#38C4B4',
    Subscription: '#8888F0',
    Medical: '#FF9878',
    'Personal Care': '#ECA8D0',
    'Professional Services': '#7EAEC8',
    Education: '#68B8F0',
    Uncategorized: '#606070',
  } as Record<string, string>,
};

export function getCategoryColor(category: string): string {
  return AppColors.categoryColors[category] ?? '#606070';
}

export const CATEGORIES = Object.keys(AppColors.categoryColors);
