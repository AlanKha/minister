import React, { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { MonthlyBarChart } from '../components/MonthlyBarChart';
import { SectionCard } from '../components/SectionCard';
import { SpendingPieChart } from '../components/SpendingPieChart';
import { WeeklyBarChart } from '../components/WeeklyBarChart';
import { useCategoryBreakdown, useMonthlyBreakdown, useWeeklyBreakdown } from '../hooks/useAnalytics';
import { AppColors, getCategoryColor } from '../theme/colors';
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

  const totalSpent = (categories ?? []).reduce((s, c) => s + Math.abs(c.totalCents), 0);
  const totalTxCount = (categories ?? []).reduce((s, c) => s + c.count, 0);

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 24, gap: 20 }}
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
          Insights
        </Text>
        <Text
          style={{
            fontSize: 30,
            fontFamily: 'Sora_700Bold',
            color: AppColors.textPrimary,
            letterSpacing: -1,
          }}
        >
          Analytics
        </Text>
      </View>

      {/* Tab bar */}
      <View
        style={{
          flexDirection: 'row',
          backgroundColor: AppColors.surfaceContainer,
          borderRadius: 10,
          padding: 3,
          gap: 2,
        }}
      >
        {TABS.map((t) => (
          <Pressable
            key={t.key}
            onPress={() => setTab(t.key)}
            style={{
              flex: 1,
              paddingVertical: 8,
              borderRadius: 8,
              backgroundColor: tab === t.key ? AppColors.surface : 'transparent',
              alignItems: 'center',
              borderWidth: tab === t.key ? 1 : 0,
              borderColor: AppColors.border,
            }}
          >
            <Text
              style={{
                fontSize: 13,
                fontFamily: tab === t.key ? 'Sora_600SemiBold' : 'Sora_400Regular',
                color: tab === t.key ? AppColors.textPrimary : AppColors.textSecondary,
              }}
            >
              {t.label}
            </Text>
          </Pressable>
        ))}
      </View>

      {tab === 'categories' && (
        <>
          {/* Summary totals */}
          {totalSpent > 0 && (
            <View style={{ flexDirection: 'row', gap: 10 }}>
              <SectionCard style={{ flex: 1 }}>
                <Text
                  style={{
                    fontSize: 10,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textTertiary,
                    letterSpacing: 1.4,
                    textTransform: 'uppercase',
                    marginBottom: 8,
                  }}
                >
                  Total Spent
                </Text>
                <Text
                  style={{
                    fontSize: 24,
                    fontFamily: 'Sora_700Bold',
                    color: AppColors.negative,
                    letterSpacing: -0.8,
                  }}
                >
                  {formatCents(-totalSpent)}
                </Text>
              </SectionCard>
              <SectionCard style={{ flex: 1 }}>
                <Text
                  style={{
                    fontSize: 10,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textTertiary,
                    letterSpacing: 1.4,
                    textTransform: 'uppercase',
                    marginBottom: 8,
                  }}
                >
                  Transactions
                </Text>
                <Text
                  style={{
                    fontSize: 24,
                    fontFamily: 'Sora_700Bold',
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  }}
                >
                  {totalTxCount}
                </Text>
              </SectionCard>
            </View>
          )}

          {/* Category chart */}
          <SectionCard>
            <Text
              style={{
                fontSize: 13,
                fontFamily: 'Sora_600SemiBold',
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
                marginBottom: 20,
              }}
            >
              Breakdown
            </Text>
            <SpendingPieChart data={categories ?? []} />
          </SectionCard>

          {/* Full category table — all categories, not just top 8 */}
          {(categories ?? []).length > 0 && (
            <SectionCard style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
              {/* Table header */}
              <View
                style={{
                  flexDirection: 'row',
                  justifyContent: 'space-between',
                  paddingHorizontal: 16,
                  paddingVertical: 10,
                  backgroundColor: AppColors.surfaceContainer,
                }}
              >
                <Text
                  style={{
                    fontSize: 10,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                    textTransform: 'uppercase',
                    flex: 1,
                  }}
                >
                  Category
                </Text>
                <Text
                  style={{
                    fontSize: 10,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                    textTransform: 'uppercase',
                    minWidth: 48,
                    textAlign: 'center',
                  }}
                >
                  Txns
                </Text>
                <Text
                  style={{
                    fontSize: 10,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                    textTransform: 'uppercase',
                    minWidth: 88,
                    textAlign: 'right',
                  }}
                >
                  Total
                </Text>
              </View>
              {[...(categories ?? [])]
                .sort((a, b) => Math.abs(b.totalCents) - Math.abs(a.totalCents))
                .map((c, i, arr) => {
                  const color = getCategoryColor(c.category);
                  return (
                    <View key={c.category}>
                      <View
                        style={{
                          flexDirection: 'row',
                          justifyContent: 'space-between',
                          alignItems: 'center',
                          paddingHorizontal: 16,
                          paddingVertical: 12,
                        }}
                      >
                        <View
                          style={{ flexDirection: 'row', alignItems: 'center', gap: 8, flex: 1 }}
                        >
                          <View
                            style={{
                              width: 8,
                              height: 8,
                              borderRadius: 2,
                              backgroundColor: color,
                            }}
                          />
                          <Text
                            style={{
                              fontSize: 13,
                              fontFamily: 'Sora_500Medium',
                              color: AppColors.textPrimary,
                            }}
                          >
                            {c.category}
                          </Text>
                        </View>
                        <Text
                          style={{
                            fontSize: 13,
                            fontFamily: 'Sora_400Regular',
                            color: AppColors.textSecondary,
                            minWidth: 48,
                            textAlign: 'center',
                          }}
                        >
                          {c.count}
                        </Text>
                        <Text
                          style={{
                            fontSize: 14,
                            fontFamily: 'Sora_700Bold',
                            color: AppColors.textPrimary,
                            minWidth: 88,
                            textAlign: 'right',
                            letterSpacing: -0.3,
                          }}
                        >
                          {c.total}
                        </Text>
                      </View>
                      {i < arr.length - 1 && (
                        <View
                          style={{
                            height: 1,
                            backgroundColor: AppColors.borderSubtle,
                            marginHorizontal: 16,
                          }}
                        />
                      )}
                    </View>
                  );
                })}
            </SectionCard>
          )}
        </>
      )}

      {tab === 'monthly' && (
        <SectionCard>
          <Text
            style={{
              fontSize: 13,
              fontFamily: 'Sora_600SemiBold',
              color: AppColors.textPrimary,
              marginBottom: 20,
            }}
          >
            Monthly Spending
          </Text>
          <MonthlyBarChart data={monthly ?? []} />
          {/* Monthly detail */}
          <View style={{ marginTop: 20, gap: 0 }}>
            {[...(monthly ?? [])].reverse().map((m, i, arr) => (
              <View
                key={m.month}
                style={{
                  flexDirection: 'row',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  paddingVertical: 11,
                  borderBottomWidth: i < arr.length - 1 ? 1 : 0,
                  borderBottomColor: AppColors.borderSubtle,
                }}
              >
                <Text
                  style={{
                    fontSize: 13,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textSecondary,
                  }}
                >
                  {m.month}
                </Text>
                <View style={{ alignItems: 'flex-end' }}>
                  <Text
                    style={{
                      fontSize: 14,
                      fontFamily: 'Sora_700Bold',
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    }}
                  >
                    {m.total}
                  </Text>
                  <Text
                    style={{
                      fontSize: 11,
                      fontFamily: 'Sora_400Regular',
                      color: AppColors.textTertiary,
                      marginTop: 1,
                    }}
                  >
                    {m.count} txns
                  </Text>
                </View>
              </View>
            ))}
          </View>
        </SectionCard>
      )}

      {tab === 'weekly' && (
        <SectionCard>
          <Text
            style={{
              fontSize: 13,
              fontFamily: 'Sora_600SemiBold',
              color: AppColors.textPrimary,
              marginBottom: 20,
            }}
          >
            Weekly Spending
          </Text>
          <WeeklyBarChart data={weekly ?? []} />
          <View style={{ marginTop: 20, gap: 0 }}>
            {[...(weekly ?? [])].reverse().map((w, i, arr) => (
              <View
                key={w.weekStart}
                style={{
                  flexDirection: 'row',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  paddingVertical: 11,
                  borderBottomWidth: i < arr.length - 1 ? 1 : 0,
                  borderBottomColor: AppColors.borderSubtle,
                }}
              >
                <Text
                  style={{
                    fontSize: 13,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textSecondary,
                  }}
                >
                  {w.weekStart}
                </Text>
                <View style={{ alignItems: 'flex-end' }}>
                  <Text
                    style={{
                      fontSize: 14,
                      fontFamily: 'Sora_700Bold',
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    }}
                  >
                    {w.total}
                  </Text>
                  <Text
                    style={{
                      fontSize: 11,
                      fontFamily: 'Sora_400Regular',
                      color: AppColors.textTertiary,
                      marginTop: 1,
                    }}
                  >
                    {w.count} txns
                  </Text>
                </View>
              </View>
            ))}
          </View>
        </SectionCard>
      )}
    </ScrollView>
  );
}
