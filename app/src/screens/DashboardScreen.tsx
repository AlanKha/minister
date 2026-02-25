import { Feather } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, Text, View } from 'react-native';
import { CardSkeleton, Skeleton } from '../components/LoadingSkeleton';
import { SectionCard } from '../components/SectionCard';
import { SpendingPieChart } from '../components/SpendingPieChart';
import { StatCard } from '../components/StatCard';
import { TransactionTile } from '../components/TransactionTile';
import { useAccounts } from '../hooks/useAccounts';
import { useCategoryBreakdown, useMonthlyBreakdown } from '../hooks/useAnalytics';
import { useTransactions } from '../hooks/useTransactions';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { monthStartISO, todayISO } from '../utils/date';

function SectionLabel({ children }: { children: string }) {
  return (
    <Text
      style={{
        fontSize: 10,
        fontFamily: 'Sora_600SemiBold',
        color: AppColors.textTertiary,
        letterSpacing: 1.6,
        textTransform: 'uppercase',
        marginBottom: 12,
      }}
    >
      {children}
    </Text>
  );
}

const CHART_MAX_H = 68;

function monthShort(monthStr: string): string {
  const [year, m] = monthStr.split('-');
  return new Date(Number(year), Number(m) - 1, 1).toLocaleString('en', { month: 'short' });
}

export function DashboardScreen() {
  const { data: accountData, isLoading: loadingAccounts } = useAccounts();
  const { data: txPage, isLoading: loadingTx } = useTransactions();
  const { data: breakdown, isLoading: loadingBreakdown } = useCategoryBreakdown({
    startDate: monthStartISO(0),
    endDate: todayISO(),
  });
  const { data: monthly, isLoading: loadingMonthly } = useMonthlyBreakdown();

  const totalSpent = breakdown?.reduce((s, d) => s + Math.abs(d.totalCents), 0) ?? 0;
  const accountCount = accountData?.accounts.length ?? 0;
  const txCount = txPage?.total ?? 0;

  // Last-month delta
  const currentMonthKey = todayISO().slice(0, 7);
  const prevMonthKey = monthStartISO(1).slice(0, 7);
  const currentMonthData = monthly?.find((m) => m.month === currentMonthKey);
  const prevMonthData = monthly?.find((m) => m.month === prevMonthKey);
  const delta =
    currentMonthData != null && prevMonthData != null
      ? Math.abs(currentMonthData.totalCents) - Math.abs(prevMonthData.totalCents)
      : null;

  // Mini trend chart: last 5 months
  const recentMonths = (monthly ?? []).slice(-5);
  const maxMonthSpend = Math.max(...recentMonths.map((m) => Math.abs(m.totalCents)), 1);

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 28, gap: 28 }}
    >
      {/* Header */}
      <View>
        <Text
          style={{
            fontSize: 10,
            fontFamily: 'Sora_600SemiBold',
            color: AppColors.accent,
            letterSpacing: 2,
            textTransform: 'uppercase',
            marginBottom: 8,
          }}
        >
          Dashboard
        </Text>
        <Text
          style={{
            fontSize: 32,
            fontFamily: 'Sora_700Bold',
            color: AppColors.textPrimary,
            letterSpacing: -1,
            lineHeight: 36,
          }}
        >
          Overview
        </Text>
        <Text
          style={{
            fontSize: 13,
            fontFamily: 'Sora_400Regular',
            color: AppColors.textTertiary,
            marginTop: 5,
          }}
        >
          Your financial snapshot this month
        </Text>
      </View>

      {/* Stats */}
      {loadingAccounts || loadingBreakdown ? (
        <View style={{ gap: 10 }}>
          <CardSkeleton />
          <View style={{ flexDirection: 'row', gap: 10 }}>
            <CardSkeleton />
            <CardSkeleton />
          </View>
        </View>
      ) : (
        <View style={{ gap: 10 }}>
          {/* Hero spending stat */}
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 16,
              padding: 24,
              borderWidth: 1,
              borderColor: AppColors.border,
            }}
          >
            <Text
              style={{
                fontSize: 10,
                fontFamily: 'Sora_600SemiBold',
                color: AppColors.textTertiary,
                letterSpacing: 1.6,
                textTransform: 'uppercase',
                marginBottom: 12,
              }}
            >
              Spent this month
            </Text>
            <Text
              style={{
                fontSize: 48,
                fontFamily: 'Sora_700Bold',
                color: AppColors.negative,
                letterSpacing: -2,
                lineHeight: 52,
              }}
            >
              {formatCents(-totalSpent)}
            </Text>
            {delta !== null && (
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 10 }}>
                <Feather
                  name={delta > 0 ? 'trending-up' : 'trending-down'}
                  size={13}
                  color={delta > 0 ? AppColors.negative : AppColors.positive}
                />
                <Text
                  style={{
                    fontSize: 12,
                    fontFamily: 'Sora_500Medium',
                    color: delta > 0 ? AppColors.negative : AppColors.positive,
                  }}
                >
                  {formatCents(Math.abs(delta))} {delta > 0 ? 'more' : 'less'} than last month
                </Text>
              </View>
            )}
          </View>

          {/* Secondary stats */}
          <View style={{ flexDirection: 'row', gap: 10 }}>
            <StatCard label="Accounts" value={String(accountCount)} flex={1} />
            <StatCard label="Transactions" value={String(txCount)} flex={1} />
          </View>
        </View>
      )}

      {/* Monthly trend chart */}
      <View>
        <SectionLabel>Monthly Trend</SectionLabel>
        <SectionCard>
          {loadingMonthly ? (
            <Skeleton height={CHART_MAX_H + 36} />
          ) : recentMonths.length === 0 ? (
            <Text
              style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, textAlign: 'center', paddingVertical: 20 }}
            >
              No data yet
            </Text>
          ) : (
            <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 6 }}>
              {recentMonths.map((m) => {
                const isCurrent = m.month === currentMonthKey;
                const barH = Math.max(6, (Math.abs(m.totalCents) / maxMonthSpend) * CHART_MAX_H);
                const label = monthShort(m.month);
                return (
                  <View key={m.month} style={{ flex: 1, alignItems: 'center', gap: 6 }}>
                    <Text
                      numberOfLines={1}
                      style={{
                        fontSize: 9,
                        fontFamily: 'Sora_500Medium',
                        color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                        letterSpacing: -0.2,
                      }}
                    >
                      {m.total}
                    </Text>
                    <View
                      style={{
                        width: '100%',
                        height: barH,
                        backgroundColor: isCurrent
                          ? AppColors.accent
                          : 'rgba(255,255,255,0.09)',
                        borderRadius: 4,
                      }}
                    />
                    <Text
                      style={{
                        fontSize: 10,
                        fontFamily: isCurrent ? 'Sora_600SemiBold' : 'Sora_400Regular',
                        color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                      }}
                    >
                      {label}
                    </Text>
                  </View>
                );
              })}
            </View>
          )}
        </SectionCard>
      </View>

      {/* Spending breakdown */}
      <View>
        <SectionLabel>Spending by Category</SectionLabel>
        <SectionCard>
          {loadingBreakdown ? (
            <View style={{ gap: 16 }}>
              <Skeleton height={14} />
              <Skeleton height={14} width="80%" />
              <Skeleton height={14} width="65%" />
              <Skeleton height={14} width="50%" />
            </View>
          ) : (
            <SpendingPieChart data={breakdown ?? []} />
          )}
        </SectionCard>
      </View>

      {/* Recent transactions */}
      <View style={{ marginBottom: 8 }}>
        <SectionLabel>Recent Transactions</SectionLabel>
        <View
          style={{
            backgroundColor: AppColors.surface,
            borderRadius: 16,
            borderWidth: 1,
            borderColor: AppColors.border,
            overflow: 'hidden',
          }}
        >
          {loadingTx ? (
            <View style={{ padding: 20, gap: 16 }}>
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} height={40} borderRadius={6} />
              ))}
            </View>
          ) : (
            txPage?.data.slice(0, 8).map((tx, i, arr) => (
              <View key={tx.id}>
                <TransactionTile transaction={tx} />
                {i < arr.length - 1 && (
                  <View
                    style={{
                      height: 1,
                      backgroundColor: AppColors.borderSubtle,
                      marginLeft: 40,
                    }}
                  />
                )}
              </View>
            ))
          )}
        </View>
      </View>
    </ScrollView>
  );
}
