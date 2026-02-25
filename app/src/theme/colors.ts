export const AppColors = {
  // Backgrounds
  background: '#F8F9FA',
  surface: '#FFFFFF',
  surfaceContainer: '#F3F4F6',
  surfaceHigh: '#E8EAED',

  // Sidebar
  sidebarBg: '#1A1A2E',
  sidebarHover: '#252540',
  sidebarActive: '#E85D3A',
  sidebarText: '#FFFFFF',
  sidebarTextMuted: 'rgba(255,255,255,0.5)',

  // Accent
  accent: '#E85D3A',
  accentLight: '#F06B4A',
  accentMuted: '#D64F28',
  accentSurface: 'rgba(232,93,58,0.07)',

  // Text
  textPrimary: '#1A1A2E',
  textSecondary: '#4A4A5A',
  textTertiary: '#8E8E9A',

  // Semantic
  positive: '#10B981',
  positiveLight: '#D1FAE5',
  negative: '#EF4444',
  negativeLight: '#FEE2E2',
  info: '#3B82F6',
  warning: '#F59E0B',

  // Borders
  border: '#E5E7EB',
  borderSubtle: '#F0F2F5',

  // Category colors
  categoryColors: {
    Dining: '#E07A6E',
    Grocery: '#6ABB8A',
    Shopping: '#BD82D6',
    Superstore: '#6BA3D6',
    Transit: '#D4A853',
    Gas: '#A68E7A',
    Rent: '#B07D62',
    Utilities: '#7A9BAE',
    Transfer: '#8DB580',
    Fee: '#8A8C94',
    Loan: '#B88A6E',
    Entertainment: '#D680B0',
    Travel: '#5CBAA3',
    Subscription: '#8A8DE0',
    Medical: '#E09878',
    'Personal Care': '#D8A8C4',
    'Professional Services': '#9CA8B8',
    Education: '#88B5D6',
    Uncategorized: '#9B9B9B',
  } as Record<string, string>,
};

export function getCategoryColor(category: string): string {
  return AppColors.categoryColors[category] ?? '#9B9B9B';
}

export const CATEGORIES = Object.keys(AppColors.categoryColors);
