import React, { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { MonthlyBarChart } from '../components/MonthlyBarChart';
import { SectionCard } from '../components/SectionCard';
import { WeeklyBarChart } from '../components/WeeklyBarChart';
import { MonthlyBreakdown, WeeklyBreakdown } from '../models/analytics';
import { useMonthlyBreakdown, useWeeklyBreakdown } from '../hooks/useAnalytics';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';

type Period = 'monthly' | 'weekly';

export function CashFlowScreen() {
  const [period, setPeriod] = useState<Period>('monthly');
  const { data: monthly } = useMonthlyBreakdown();
  const { data: weekly } = useWeeklyBreakdown();

  const monthlyTotal = monthly?.reduce((s, d) => s + Math.abs(d.totalCents), 0) ?? 0;
  const weeklyAvg =
    weekly && weekly.length > 0
      ? weekly.reduce((s, d) => s + Math.abs(d.totalCents), 0) / weekly.length
      : 0;

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
        Cash Flow
      </Text>

      {/* Summary */}
      <View style={{ flexDirection: 'row', gap: 16 }}>
        <SectionCard style={{ flex: 1 }}>
          <Text style={{ fontSize: 11, fontFamily: 'Sora_500Medium', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>
            Total (all months)
          </Text>
          <Text style={{ fontSize: 24, fontFamily: 'Sora_700Bold', color: AppColors.negative }}>
            {formatCents(-monthlyTotal)}
          </Text>
        </SectionCard>
        <SectionCard style={{ flex: 1 }}>
          <Text style={{ fontSize: 11, fontFamily: 'Sora_500Medium', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>
            Avg per week
          </Text>
          <Text style={{ fontSize: 24, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary }}>
            {formatCents(-weeklyAvg)}
          </Text>
        </SectionCard>
      </View>

      {/* Tab switch */}
      <View style={{ flexDirection: 'row', gap: 8 }}>
        {(['monthly', 'weekly'] as Period[]).map((p) => (
          <Pressable
            key={p}
            onPress={() => setPeriod(p)}
            style={{
              paddingHorizontal: 16,
              paddingVertical: 8,
              borderRadius: 20,
              backgroundColor: period === p ? AppColors.accent : AppColors.surface,
              borderWidth: 1,
              borderColor: period === p ? AppColors.accent : AppColors.border,
            }}
          >
            <Text
              style={{
                fontSize: 13,
                fontFamily: 'Sora_500Medium',
                color: period === p ? '#fff' : AppColors.textSecondary,
                textTransform: 'capitalize',
              }}
            >
              {p}
            </Text>
          </Pressable>
        ))}
      </View>

      {/* Chart */}
      <SectionCard>
        <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 20 }}>
          {period === 'monthly' ? 'Monthly Spending' : 'Weekly Spending'}
        </Text>
        {period === 'monthly' ? (
          <MonthlyBarChart data={monthly ?? []} />
        ) : (
          <WeeklyBarChart data={weekly ?? []} />
        )}
      </SectionCard>

      {/* Detail table */}
      <SectionCard>
        <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 16 }}>
          {period === 'monthly' ? 'By Month' : 'By Week'}
        </Text>
        {(period === 'monthly' ? monthly ?? [] : weekly ?? []).map((item) => {
          const label = period === 'monthly'
            ? (item as MonthlyBreakdown).month
            : (item as WeeklyBreakdown).weekStart;
          return (
            <View
              key={label}
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                paddingVertical: 10,
                borderBottomWidth: 1,
                borderBottomColor: AppColors.borderSubtle,
              }}
            >
              <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textSecondary }}>
                {label}
              </Text>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary }}>
                  {item.total}
                </Text>
                <Text style={{ fontSize: 11, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
                  {item.count} transactions
                </Text>
              </View>
            </View>
          );
        })}
      </SectionCard>
    </ScrollView>
  );
}
