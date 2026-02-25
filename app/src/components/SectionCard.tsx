import React from 'react';
import { View, ViewStyle } from 'react-native';
import { AppColors } from '../theme/colors';

interface SectionCardProps {
  children: React.ReactNode;
  style?: ViewStyle;
}

export function SectionCard({ children, style }: SectionCardProps) {
  return (
    <View
      style={[
        {
          backgroundColor: AppColors.surface,
          borderRadius: 16,
          padding: 20,
          borderWidth: 1,
          borderColor: AppColors.border,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
