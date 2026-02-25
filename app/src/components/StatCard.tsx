import React from 'react';
import { Text, View } from 'react-native';
import { AppColors } from '../theme/colors';

interface StatCardProps {
  label: string;
  value: string;
  sub?: string;
  color?: string;
}

export function StatCard({ label, value, sub, color }: StatCardProps) {
  return (
    <View
      style={{
        backgroundColor: AppColors.surface,
        borderRadius: 16,
        padding: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.06,
        shadowRadius: 6,
        elevation: 2,
        minWidth: 140,
      }}
    >
      <Text
        style={{
          fontSize: 11,
          fontFamily: 'Sora_500Medium',
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
          textTransform: 'uppercase',
          marginBottom: 8,
        }}
      >
        {label}
      </Text>
      <Text
        style={{
          fontSize: 26,
          fontFamily: 'Sora_700Bold',
          color: color ?? AppColors.textPrimary,
          letterSpacing: -0.5,
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
            marginTop: 4,
          }}
        >
          {sub}
        </Text>
      )}
    </View>
  );
}
