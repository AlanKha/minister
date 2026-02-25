import { Feather } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import React from 'react';
import { FlatList, Pressable, Text, View } from 'react-native';
import { FilterBar } from '../components/FilterBar';
import { Skeleton } from '../components/LoadingSkeleton';
import { TransactionTile } from '../components/TransactionTile';
import { useAccounts } from '../hooks/useAccounts';
import { useTransactions } from '../hooks/useTransactions';
import { CleanTransaction } from '../models/transaction';
import { useTransactionStore } from '../stores/transactionStore';
import { AppColors } from '../theme/colors';
import { formatDate } from '../utils/date';

function groupByDate(transactions: CleanTransaction[]): { date: string; items: CleanTransaction[] }[] {
  const map = new Map<string, CleanTransaction[]>();
  for (const tx of transactions) {
    const existing = map.get(tx.date) ?? [];
    existing.push(tx);
    map.set(tx.date, existing);
  }
  return Array.from(map.entries()).map(([date, items]) => ({ date, items }));
}

export function TransactionsScreen() {
  const { data: txPage, isLoading } = useTransactions();
  const { data: accountData } = useAccounts();
  const { filters, setFilter } = useTransactionStore();

  const grouped = groupByDate(txPage?.data ?? []);
  const totalPages = txPage?.totalPages ?? 1;

  type Section = { type: 'header'; date: string } | { type: 'item'; tx: CleanTransaction };

  const listData: Section[] = grouped.flatMap(({ date, items }) => [
    { type: 'header' as const, date },
    ...items.map((tx) => ({ type: 'item' as const, tx })),
  ]);

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.background }}>
      {/* Top bar */}
      <View
        style={{
          paddingHorizontal: 24,
          paddingTop: 24,
          paddingBottom: 0,
          backgroundColor: AppColors.background,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <Text
            style={{
              fontSize: 26,
              fontFamily: 'Sora_700Bold',
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            }}
          >
            Transactions
          </Text>
          {txPage && (
            <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
              {txPage.total} total
            </Text>
          )}
        </View>
        <FilterBar accounts={accountData?.accounts} />
      </View>

      {/* List */}
      {isLoading ? (
        <View style={{ padding: 24, gap: 12 }}>
          {[...Array(6)].map((_, i) => <Skeleton key={i} height={52} borderRadius={8} />)}
        </View>
      ) : (
        <FlatList
          data={listData}
          keyExtractor={(item, i) => (item.type === 'header' ? `h-${item.date}` : `tx-${item.tx.id}-${i}`)}
          renderItem={({ item }) => {
            if (item.type === 'header') {
              return (
                <View
                  style={{
                    paddingHorizontal: 24,
                    paddingTop: 20,
                    paddingBottom: 8,
                  }}
                >
                  <Text
                    style={{
                      fontSize: 12,
                      fontFamily: 'Sora_600SemiBold',
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                      textTransform: 'uppercase',
                    }}
                  >
                    {formatDate(item.date)}
                  </Text>
                </View>
              );
            }
            return (
              <View style={{ paddingHorizontal: 16 }}>
                <View
                  style={{
                    backgroundColor: AppColors.surface,
                    borderRadius: 12,
                    overflow: 'hidden',
                    marginBottom: 2,
                  }}
                >
                  <TransactionTile transaction={item.tx} />
                </View>
              </View>
            );
          }}
          ListFooterComponent={
            totalPages > 1 ? (
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 12,
                  padding: 20,
                }}
              >
                <Pressable
                  onPress={() => setFilter('page', Math.max(1, filters.page - 1))}
                  disabled={filters.page <= 1}
                  style={{
                    padding: 8,
                    borderRadius: 8,
                    backgroundColor: AppColors.surface,
                    opacity: filters.page <= 1 ? 0.4 : 1,
                  }}
                >
                  <Feather name="chevron-left" size={18} color={AppColors.textSecondary} />
                </Pressable>
                <Text style={{ fontSize: 13, fontFamily: 'Sora_500Medium', color: AppColors.textSecondary }}>
                  Page {filters.page} of {totalPages}
                </Text>
                <Pressable
                  onPress={() => setFilter('page', Math.min(totalPages, filters.page + 1))}
                  disabled={filters.page >= totalPages}
                  style={{
                    padding: 8,
                    borderRadius: 8,
                    backgroundColor: AppColors.surface,
                    opacity: filters.page >= totalPages ? 0.4 : 1,
                  }}
                >
                  <Feather name="chevron-right" size={18} color={AppColors.textSecondary} />
                </Pressable>
              </View>
            ) : null
          }
        />
      )}
    </View>
  );
}
