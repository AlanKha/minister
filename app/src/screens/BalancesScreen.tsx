import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { CardSkeleton } from '../components/LoadingSkeleton';
import { SectionCard } from '../components/SectionCard';
import { useBalances, useRefreshBalances } from '../hooks/useBalances';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { formatDate } from '../utils/date';

export function BalancesScreen() {
  const { data: balances, isLoading } = useBalances();
  const { mutate: refresh, isPending } = useRefreshBalances();

  const netWorth = balances?.reduce((s, b) => s + b.balanceCents, 0) ?? 0;

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 24, gap: 20 }}
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
          Balances
        </Text>
        <Pressable
          onPress={() => refresh(undefined)}
          disabled={isPending}
          style={({ pressed }) => ({
            flexDirection: 'row',
            alignItems: 'center',
            gap: 6,
            paddingHorizontal: 14,
            paddingVertical: 8,
            borderRadius: 10,
            backgroundColor: pressed ? AppColors.accentSurface : AppColors.surface,
            borderWidth: 1,
            borderColor: AppColors.border,
            opacity: isPending ? 0.6 : 1,
          })}
        >
          <Feather name="refresh-cw" size={14} color={AppColors.accent} />
          <Text style={{ fontSize: 13, fontFamily: 'Sora_500Medium', color: AppColors.accent }}>
            {isPending ? 'Refreshing…' : 'Refresh'}
          </Text>
        </Pressable>
      </View>

      {/* Net worth summary */}
      {!isLoading && (
        <SectionCard>
          <Text style={{ fontSize: 11, fontFamily: 'Sora_500Medium', color: AppColors.textTertiary, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>
            Net Balance
          </Text>
          <Text
            style={{
              fontSize: 32,
              fontFamily: 'Sora_700Bold',
              color: netWorth >= 0 ? AppColors.positive : AppColors.negative,
              letterSpacing: -1,
            }}
          >
            {formatCents(netWorth)}
          </Text>
        </SectionCard>
      )}

      {isLoading ? (
        <View style={{ gap: 12 }}>
          {[...Array(3)].map((_, i) => <CardSkeleton key={i} />)}
        </View>
      ) : (
        balances?.map((b) => (
          <SectionCard key={b.accountId}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 15, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary }}>
                  {b.accountLabel}
                </Text>
                <Text style={{ fontSize: 11, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 4 }}>
                  As of {formatDate(b.asOf)} · {b.currency}
                </Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={{ fontSize: 20, fontFamily: 'Sora_700Bold', color: b.balanceCents >= 0 ? AppColors.textPrimary : AppColors.negative }}>
                  {formatCents(b.balanceCents)}
                </Text>
                {b.availableCents != null && (
                  <Text style={{ fontSize: 11, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 2 }}>
                    {formatCents(b.availableCents)} available
                  </Text>
                )}
              </View>
            </View>
          </SectionCard>
        ))
      )}
    </ScrollView>
  );
}
