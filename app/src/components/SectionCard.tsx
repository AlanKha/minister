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
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 1 },
          shadowOpacity: 0.06,
          shadowRadius: 6,
          elevation: 2,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
