import React from 'react';
import { Text, View } from 'react-native';
import { AppColors } from '../theme/colors';

interface StatCardProps {
  label: string;
  value: string;
  sub?: string;
  color?: string;
  flex?: number;
}

export function StatCard({ label, value, sub, color, flex }: StatCardProps) {
  return (
    <View
      style={{
        backgroundColor: AppColors.surface,
        borderRadius: 14,
        padding: 20,
        borderWidth: 1,
        borderColor: AppColors.border,
        flex,
        minWidth: 110,
      }}
    >
      <Text
        style={{
          fontSize: 10,
          fontFamily: 'Sora_600SemiBold',
          color: AppColors.textTertiary,
          letterSpacing: 1.4,
          textTransform: 'uppercase',
          marginBottom: 10,
        }}
      >
        {label}
      </Text>
      <Text
        style={{
          fontSize: 30,
          fontFamily: 'Sora_700Bold',
          color: color ?? AppColors.textPrimary,
          letterSpacing: -1,
          lineHeight: 34,
        }}
      >
        {value}
      </Text>
      {sub != null && (
        <Text
          style={{
            fontSize: 12,
            fontFamily: 'Sora_400Regular',
            color: AppColors.textTertiary,
            marginTop: 6,
          }}
        >
          {sub}
        </Text>
      )}
    </View>
  );
}
