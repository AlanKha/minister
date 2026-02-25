import React, { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { MonthlyBarChart } from '../components/MonthlyBarChart';
import { SectionCard } from '../components/SectionCard';
import { SpendingPieChart } from '../components/SpendingPieChart';
import { WeeklyBarChart } from '../components/WeeklyBarChart';
import { useCategoryBreakdown, useMonthlyBreakdown, useWeeklyBreakdown } from '../hooks/useAnalytics';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';

type Tab = 'categories' | 'monthly' | 'weekly';
const TABS: { key: Tab; label: string }[] = [
  { key: 'categories', label: 'Categories' },
  { key: 'monthly', label: 'Monthly' },
  { key: 'weekly', label: 'Weekly' },
];

export function AnalyticsScreen() {
  const [tab, setTab] = useState<Tab>('categories');
  const { data: categories } = useCategoryBreakdown();
  const { data: monthly } = useMonthlyBreakdown();
  const { data: weekly } = useWeeklyBreakdown();

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 24, gap: 20 }}
    >
      <Text
        style={{
          fontSize: 26,
          fontFamily: 'Sora_700Bold',
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          marginBottom: 4,
        }}
      >
        Analytics
      </Text>

      {/* Tab bar */}
      <View style={{ flexDirection: 'row', gap: 8 }}>
        {TABS.map((t) => (
          <Pressable
            key={t.key}
            onPress={() => setTab(t.key)}
            style={{
              paddingHorizontal: 18,
              paddingVertical: 9,
              borderRadius: 20,
              backgroundColor: tab === t.key ? AppColors.accent : AppColors.surface,
              borderWidth: 1,
              borderColor: tab === t.key ? AppColors.accent : AppColors.border,
            }}
          >
            <Text
              style={{
                fontSize: 13,
                fontFamily: 'Sora_500Medium',
                color: tab === t.key ? '#fff' : AppColors.textSecondary,
              }}
            >
              {t.label}
            </Text>
          </Pressable>
        ))}
      </View>

      {/* Content */}
      {tab === 'categories' && (
        <SectionCard>
          <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 20 }}>
            Spending by Category
          </Text>
          <SpendingPieChart data={categories ?? []} />
          {/* Summary table */}
          <View style={{ marginTop: 24, borderTopWidth: 1, borderTopColor: AppColors.borderSubtle, paddingTop: 16 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 12 }}>
              <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase' }}>Category</Text>
              <View style={{ flexDirection: 'row', gap: 48 }}>
                <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase' }}>Count</Text>
                <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase', minWidth: 80, textAlign: 'right' }}>Total</Text>
              </View>
            </View>
            {(categories ?? []).map((c) => (
              <View key={c.category} style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: AppColors.borderSubtle }}>
                <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textPrimary }}>{c.category}</Text>
                <View style={{ flexDirection: 'row', gap: 48 }}>
                  <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textSecondary, textAlign: 'center', minWidth: 40 }}>{c.count}</Text>
                  <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, minWidth: 80, textAlign: 'right' }}>{c.total}</Text>
                </View>
              </View>
            ))}
          </View>
        </SectionCard>
      )}

      {tab === 'monthly' && (
        <SectionCard>
          <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 20 }}>
            Monthly Spending
          </Text>
          <MonthlyBarChart data={monthly ?? []} />
        </SectionCard>
      )}

      {tab === 'weekly' && (
        <SectionCard>
          <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 20 }}>
            Weekly Spending
          </Text>
          <WeeklyBarChart data={weekly ?? []} />
        </SectionCard>
      )}
    </ScrollView>
  );
}
