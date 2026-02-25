import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { CardSkeleton } from '../components/LoadingSkeleton';
import { SectionCard } from '../components/SectionCard';
import { useAccounts } from '../hooks/useAccounts';
import { AppColors } from '../theme/colors';
import { formatDate } from '../utils/date';

export function AccountsScreen() {
  const { data, isLoading, refetch } = useAccounts();

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
          Accounts
        </Text>
        <Pressable
          onPress={() => refetch()}
          style={{
            padding: 8,
            borderRadius: 8,
            backgroundColor: AppColors.surface,
          }}
        >
          <Feather name="refresh-cw" size={16} color={AppColors.textSecondary} />
        </Pressable>
      </View>

      {isLoading ? (
        <View style={{ gap: 12 }}>
          {[...Array(3)].map((_, i) => <CardSkeleton key={i} />)}
        </View>
      ) : data?.accounts.length === 0 ? (
        <SectionCard style={{ alignItems: 'center', paddingVertical: 40 }}>
          <Feather name="credit-card" size={40} color={AppColors.textTertiary} />
          <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginTop: 16 }}>
            No accounts linked
          </Text>
          <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 8 }}>
            Connect a bank account to get started
          </Text>
        </SectionCard>
      ) : (
        data?.accounts.map((account) => (
          <SectionCard key={account.id}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <View
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                  backgroundColor: AppColors.accentSurface,
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginRight: 16,
                }}
              >
                <Feather name="credit-card" size={20} color={AppColors.accent} />
              </View>
              <View style={{ flex: 1 }}>
                <Text
                  style={{
                    fontSize: 15,
                    fontFamily: 'Sora_600SemiBold',
                    color: AppColors.textPrimary,
                  }}
                >
                  {account.label}
                </Text>
                {account.institution && (
                  <Text
                    style={{
                      fontSize: 13,
                      fontFamily: 'Sora_400Regular',
                      color: AppColors.textSecondary,
                      marginTop: 2,
                    }}
                  >
                    {account.institution}
                  </Text>
                )}
                <Text
                  style={{
                    fontSize: 11,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textTertiary,
                    marginTop: 4,
                  }}
                >
                  Linked {formatDate(account.linkedAt)}
                </Text>
              </View>
              <View
                style={{
                  paddingHorizontal: 10,
                  paddingVertical: 4,
                  borderRadius: 20,
                  backgroundColor: AppColors.positiveLight,
                }}
              >
                <Text style={{ fontSize: 11, fontFamily: 'Sora_500Medium', color: AppColors.positive }}>
                  Active
                </Text>
              </View>
            </View>
          </SectionCard>
        ))
      )}
    </ScrollView>
  );
}
