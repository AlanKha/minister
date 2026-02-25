import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { CleanTransaction } from '../models/transaction';
import { AppColors, getCategoryColor } from '../theme/colors';
import { formatCents } from '../utils/currency';

interface TransactionTileProps {
  transaction: CleanTransaction;
  onPress?: () => void;
}

export function TransactionTile({ transaction, onPress }: TransactionTileProps) {
  const isExpense = transaction.amount < 0;
  const amountColor = isExpense ? AppColors.negative : AppColors.positive;
  const categoryColor = getCategoryColor(transaction.category);

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 14,
        paddingHorizontal: 18,
        backgroundColor: pressed ? AppColors.surfaceContainer : 'transparent',
      })}
    >
      {/* Category dot */}
      <View
        style={{
          width: 8,
          height: 8,
          borderRadius: 4,
          backgroundColor: categoryColor,
          marginRight: 14,
          flexShrink: 0,
        }}
      />

      {/* Description + meta */}
      <View style={{ flex: 1, marginRight: 12 }}>
        <Text
          numberOfLines={1}
          style={{
            fontSize: 13,
            fontFamily: 'Sora_500Medium',
            color: AppColors.textPrimary,
            marginBottom: 3,
          }}
        >
          {transaction.description}
        </Text>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
          <Text
            style={{
              fontSize: 10,
              fontFamily: 'Sora_600SemiBold',
              color: categoryColor,
              letterSpacing: 0.3,
            }}
          >
            {transaction.category}
          </Text>
          <Text style={{ fontSize: 10, color: AppColors.textTertiary, fontFamily: 'Sora_400Regular' }}>·</Text>
          <Text
            style={{
              fontSize: 10,
              fontFamily: 'Sora_400Regular',
              color: AppColors.textTertiary,
            }}
          >
            {transaction.accountLabel}
          </Text>
        </View>
      </View>

      {/* Amount + pin */}
      <View style={{ alignItems: 'flex-end', gap: 3 }}>
        <Text
          style={{
            fontSize: 14,
            fontFamily: 'Sora_700Bold',
            color: amountColor,
            letterSpacing: -0.3,
          }}
        >
          {formatCents(transaction.amount)}
        </Text>
        {transaction.pinned && (
          <Feather name="bookmark" size={10} color={AppColors.accent} />
        )}
      </View>
    </Pressable>
  );
}
