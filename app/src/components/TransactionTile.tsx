import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { CleanTransaction } from '../models/transaction';
import { AppColors, getCategoryColor } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { CategoryChip } from './CategoryChip';

interface TransactionTileProps {
  transaction: CleanTransaction;
  onPress?: () => void;
}

export function TransactionTile({ transaction, onPress }: TransactionTileProps) {
  const isExpense = transaction.amount < 0;
  const amountColor = isExpense ? AppColors.textPrimary : AppColors.positive;
  const categoryColor = getCategoryColor(transaction.category);

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 16,
        backgroundColor: pressed ? AppColors.surfaceContainer : AppColors.surface,
      })}
    >
      {/* Category dot */}
      <View
        style={{
          width: 36,
          height: 36,
          borderRadius: 18,
          backgroundColor: categoryColor + '22',
          alignItems: 'center',
          justifyContent: 'center',
          marginRight: 12,
        }}
      >
        <View
          style={{
            width: 10,
            height: 10,
            borderRadius: 5,
            backgroundColor: categoryColor,
          }}
        />
      </View>

      {/* Description + category */}
      <View style={{ flex: 1 }}>
        <Text
          numberOfLines={1}
          style={{
            fontSize: 14,
            fontFamily: 'Sora_500Medium',
            color: AppColors.textPrimary,
            marginBottom: 3,
          }}
        >
          {transaction.description}
        </Text>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
          <CategoryChip category={transaction.category} small />
          <Text
            style={{
              fontSize: 11,
              fontFamily: 'Sora_400Regular',
              color: AppColors.textTertiary,
            }}
          >
            {transaction.accountLabel}
          </Text>
        </View>
      </View>

      {/* Amount + pin */}
      <View style={{ alignItems: 'flex-end', gap: 4 }}>
        <Text
          style={{
            fontSize: 15,
            fontFamily: 'Sora_600SemiBold',
            color: amountColor,
          }}
        >
          {formatCents(transaction.amount)}
        </Text>
        {transaction.pinned && (
          <Feather name="bookmark" size={12} color={AppColors.accent} />
        )}
      </View>
    </Pressable>
  );
}
