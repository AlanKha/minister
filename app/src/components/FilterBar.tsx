import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { LinkedAccount } from '../models/account';
import { useTransactionStore } from '../stores/transactionStore';
import { AppColors, CATEGORIES } from '../theme/colors';

interface FilterBarProps {
  accounts?: LinkedAccount[];
}

export function FilterBar({ accounts = [] }: FilterBarProps) {
  const { filters, setFilter, resetFilters } = useTransactionStore();
  const hasFilters =
    filters.account || filters.category || filters.startDate || filters.endDate || filters.search;

  return (
    <View style={{ paddingVertical: 12, gap: 8 }}>
      {/* Search bar */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          backgroundColor: AppColors.surface,
          borderRadius: 10,
          paddingHorizontal: 12,
          height: 38,
          borderWidth: 1,
          borderColor: AppColors.border,
        }}
      >
        <Feather name="search" size={15} color={AppColors.textTertiary} />
        <TextInput
          style={{
            flex: 1,
            marginLeft: 8,
            fontSize: 13,
            fontFamily: 'Sora_400Regular',
            color: AppColors.textPrimary,
          }}
          placeholder="Search transactions…"
          placeholderTextColor={AppColors.textTertiary}
          value={filters.search ?? ''}
          onChangeText={(v) => setFilter('search', v || undefined)}
        />
        {filters.search ? (
          <Pressable onPress={() => setFilter('search', undefined)}>
            <Feather name="x" size={14} color={AppColors.textTertiary} />
          </Pressable>
        ) : null}
      </View>

      {/* Pill filters */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ flexDirection: 'row' }}>
        <View style={{ flexDirection: 'row', gap: 8, paddingRight: 16 }}>
          {/* Account filter */}
          {accounts.length > 0 && (
            <FilterPill
              label={filters.account ? accounts.find((a) => a.id === filters.account)?.label ?? 'Account' : 'Account'}
              active={!!filters.account}
              onClear={() => setFilter('account', undefined)}
            />
          )}

          {/* Category filter */}
          <FilterPill
            label={filters.category ?? 'Category'}
            active={!!filters.category}
            onClear={() => setFilter('category', undefined)}
          />

          {/* Sort */}
          <FilterPill
            label={filters.sort === 'date_desc' ? 'Newest' : filters.sort === 'date_asc' ? 'Oldest' : 'Amount'}
            active={false}
            onPress={() => {
              const next =
                filters.sort === 'date_desc'
                  ? 'date_asc'
                  : filters.sort === 'date_asc'
                  ? 'amount_desc'
                  : 'date_desc';
              setFilter('sort', next);
            }}
          />

          {/* Clear all */}
          {hasFilters && (
            <Pressable
              onPress={resetFilters}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                paddingHorizontal: 12,
                paddingVertical: 6,
                borderRadius: 20,
                backgroundColor: AppColors.negativeLight,
                gap: 4,
              }}
            >
              <Feather name="x" size={12} color={AppColors.negative} />
              <Text style={{ fontSize: 12, fontFamily: 'Sora_500Medium', color: AppColors.negative }}>
                Clear
              </Text>
            </Pressable>
          )}
        </View>
      </ScrollView>
    </View>
  );
}

interface FilterPillProps {
  label: string;
  active?: boolean;
  onPress?: () => void;
  onClear?: () => void;
}

function FilterPill({ label, active = false, onPress, onClear }: FilterPillProps) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 20,
        backgroundColor: active ? AppColors.accentSurface : pressed ? AppColors.surfaceContainer : AppColors.surface,
        borderWidth: 1,
        borderColor: active ? AppColors.accent : AppColors.border,
        gap: 4,
      })}
    >
      <Text
        style={{
          fontSize: 12,
          fontFamily: 'Sora_500Medium',
          color: active ? AppColors.accent : AppColors.textSecondary,
        }}
      >
        {label}
      </Text>
      {active && onClear && (
        <Pressable onPress={onClear}>
          <Feather name="x" size={11} color={AppColors.accent} />
        </Pressable>
      )}
    </Pressable>
  );
}
