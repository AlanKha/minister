import React from 'react';
import { ScrollView, Text, View } from 'react-native';
import { CardSkeleton, Skeleton } from '../components/LoadingSkeleton';
import { SectionCard } from '../components/SectionCard';
import { SpendingPieChart } from '../components/SpendingPieChart';
import { StatCard } from '../components/StatCard';
import { TransactionTile } from '../components/TransactionTile';
import { useAccounts } from '../hooks/useAccounts';
import { useCategoryBreakdown } from '../hooks/useAnalytics';
import { useTransactions } from '../hooks/useTransactions';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { monthStartISO, todayISO } from '../utils/date';

export function DashboardScreen() {
  const { data: accountData, isLoading: loadingAccounts } = useAccounts();
  const { data: txPage, isLoading: loadingTx } = useTransactions();
  const { data: breakdown, isLoading: loadingBreakdown } = useCategoryBreakdown({
    startDate: monthStartISO(0),
    endDate: todayISO(),
  });

  const totalSpent = breakdown?.reduce((s, d) => s + Math.abs(d.totalCents), 0) ?? 0;
  const accountCount = accountData?.accounts.length ?? 0;
  const txCount = txPage?.total ?? 0;

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 24, gap: 20 }}
    >
      {/* Header */}
      <View style={{ marginBottom: 4 }}>
        <Text
          style={{
            fontSize: 26,
            fontFamily: 'Sora_700Bold',
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          }}
        >
          Overview
        </Text>
        <Text
          style={{
            fontSize: 13,
            fontFamily: 'Sora_400Regular',
            color: AppColors.textTertiary,
            marginTop: 4,
          }}
        >
          Your financial snapshot this month
        </Text>
      </View>

      {/* Stat cards */}
      {loadingAccounts || loadingBreakdown ? (
        <View style={{ flexDirection: 'row', gap: 16 }}>
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
        </View>
      ) : (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 16 }}>
          <StatCard label="Spent this month" value={formatCents(-totalSpent)} color={AppColors.negative} />
          <StatCard label="Accounts" value={String(accountCount)} />
          <StatCard label="Transactions" value={String(txCount)} />
        </View>
      )}

      {/* Spending breakdown */}
      <SectionCard>
        <Text
          style={{
            fontSize: 16,
            fontFamily: 'Sora_600SemiBold',
            color: AppColors.textPrimary,
            marginBottom: 16,
          }}
        >
          Spending by Category
        </Text>
        {loadingBreakdown ? (
          <View style={{ gap: 12 }}>
            <Skeleton height={12} />
            <Skeleton height={12} width="80%" />
            <Skeleton height={12} width="60%" />
          </View>
        ) : (
          <SpendingPieChart data={breakdown ?? []} />
        )}
      </SectionCard>

      {/* Recent transactions */}
      <SectionCard style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
        <View style={{ paddingHorizontal: 20, paddingTop: 20, paddingBottom: 12 }}>
          <Text
            style={{
              fontSize: 16,
              fontFamily: 'Sora_600SemiBold',
              color: AppColors.textPrimary,
            }}
          >
            Recent Transactions
          </Text>
        </View>
        {loadingTx ? (
          <View style={{ padding: 20, gap: 12 }}>
            {[...Array(4)].map((_, i) => (
              <Skeleton key={i} height={44} borderRadius={8} />
            ))}
          </View>
        ) : (
          txPage?.data.slice(0, 8).map((tx, i, arr) => (
            <View key={tx.id}>
              <TransactionTile transaction={tx} />
              {i < arr.length - 1 && (
                <View style={{ height: 1, backgroundColor: AppColors.borderSubtle, marginLeft: 64 }} />
              )}
            </View>
          ))
        )}
      </SectionCard>
    </ScrollView>
  );
}
