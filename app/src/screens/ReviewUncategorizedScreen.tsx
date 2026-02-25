import { Feather } from '@expo/vector-icons';
import React, { useState } from 'react';
import { FlatList, Pressable, Switch, Text, View } from 'react-native';
import { Skeleton } from '../components/LoadingSkeleton';
import { useUncategorizedTransactions } from '../hooks/useTransactions';
import { useQueryClient, useMutation } from '@tanstack/react-query';
import { categorizeTransaction } from '../api/apiClient';
import { AppColors, CATEGORIES } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { formatDate } from '../utils/date';

export function ReviewUncategorizedScreen() {
  const { data: transactions, isLoading } = useUncategorizedTransactions();
  const qc = useQueryClient();
  const [expanded, setExpanded] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<Record<string, string>>({});
  const [createRule, setCreateRule] = useState<Record<string, boolean>>({});

  const { mutate: categorize } = useMutation({
    mutationFn: ({ id, category, rule }: { id: string; category: string; rule: boolean }) =>
      categorizeTransaction(id, category, rule),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['transactions', 'uncategorized'] });
      qc.invalidateQueries({ queryKey: ['transactions'] });
    },
  });

  function handleApply(id: string) {
    const category = selectedCategory[id] ?? CATEGORIES[0];
    const rule = createRule[id] ?? false;
    categorize({ id, category, rule });
    setExpanded(null);
  }

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.background }}>
      {/* Header */}
      <View style={{ paddingHorizontal: 24, paddingTop: 24, paddingBottom: 16 }}>
        <Text style={{ fontSize: 26, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary, letterSpacing: -0.5 }}>
          Review Uncategorized
        </Text>
        <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 4 }}>
          {transactions?.length ?? 0} transactions to review
        </Text>
      </View>

      {isLoading ? (
        <View style={{ padding: 24, gap: 12 }}>
          {[...Array(5)].map((_, i) => <Skeleton key={i} height={56} borderRadius={12} />)}
        </View>
      ) : !transactions?.length ? (
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <Feather name="check-circle" size={48} color={AppColors.positive} />
          <Text style={{ fontSize: 18, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginTop: 16 }}>
            All caught up!
          </Text>
          <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 8 }}>
            No uncategorized transactions
          </Text>
        </View>
      ) : (
        <FlatList
          data={transactions}
          keyExtractor={(t) => t.id}
          contentContainerStyle={{ paddingHorizontal: 16, gap: 8, paddingBottom: 24 }}
          renderItem={({ item: tx }) => {
            const isExpanded = expanded === tx.id;
            const cat = selectedCategory[tx.id] ?? CATEGORIES[0];
            const rule = createRule[tx.id] ?? false;

            return (
              <View
                style={{
                  backgroundColor: AppColors.surface,
                  borderRadius: 14,
                  overflow: 'hidden',
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 1 },
                  shadowOpacity: 0.05,
                  shadowRadius: 4,
                }}
              >
                <Pressable
                  onPress={() => setExpanded(isExpanded ? null : tx.id)}
                  style={{ flexDirection: 'row', alignItems: 'center', padding: 16 }}
                >
                  <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 14, fontFamily: 'Sora_500Medium', color: AppColors.textPrimary }} numberOfLines={1}>
                      {tx.description}
                    </Text>
                    <Text style={{ fontSize: 12, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 3 }}>
                      {formatDate(tx.date)} · {tx.accountLabel}
                    </Text>
                  </View>
                  <Text style={{ fontSize: 15, fontFamily: 'Sora_600SemiBold', color: tx.amount < 0 ? AppColors.textPrimary : AppColors.positive, marginRight: 12 }}>
                    {formatCents(tx.amount)}
                  </Text>
                  <Feather name={isExpanded ? 'chevron-up' : 'chevron-down'} size={16} color={AppColors.textTertiary} />
                </Pressable>

                {isExpanded && (
                  <View style={{ borderTopWidth: 1, borderTopColor: AppColors.borderSubtle, padding: 16, gap: 12 }}>
                    {/* Category picker */}
                    <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary, letterSpacing: 0.3 }}>
                      SELECT CATEGORY
                    </Text>
                    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
                      {CATEGORIES.map((c) => (
                        <Pressable
                          key={c}
                          onPress={() => setSelectedCategory((s) => ({ ...s, [tx.id]: c }))}
                          style={{
                            paddingHorizontal: 10,
                            paddingVertical: 5,
                            borderRadius: 14,
                            backgroundColor: cat === c ? AppColors.accent : AppColors.surfaceContainer,
                          }}
                        >
                          <Text style={{ fontSize: 12, fontFamily: 'Sora_500Medium', color: cat === c ? '#fff' : AppColors.textSecondary }}>
                            {c}
                          </Text>
                        </Pressable>
                      ))}
                    </View>

                    {/* Create rule toggle */}
                    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                      <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textPrimary }}>
                        Also create a rule
                      </Text>
                      <Switch
                        value={rule}
                        onValueChange={(v) => setCreateRule((s) => ({ ...s, [tx.id]: v }))}
                        trackColor={{ true: AppColors.accent }}
                      />
                    </View>

                    {/* Apply */}
                    <Pressable
                      onPress={() => handleApply(tx.id)}
                      style={({ pressed }) => ({
                        paddingVertical: 11,
                        borderRadius: 12,
                        backgroundColor: AppColors.accent,
                        opacity: pressed ? 0.85 : 1,
                        alignItems: 'center',
                      })}
                    >
                      <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: '#fff' }}>
                        Apply — {cat}
                      </Text>
                    </Pressable>
                  </View>
                )}
              </View>
            );
          }}
        />
      )}
    </View>
  );
}
