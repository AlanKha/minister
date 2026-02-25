import React from 'react';
import { Text, View } from 'react-native';
import { getCategoryColor } from '../theme/colors';

interface CategoryChipProps {
  category: string;
  small?: boolean;
}

export function CategoryChip({ category, small = false }: CategoryChipProps) {
  const color = getCategoryColor(category);

  return (
    <View
      style={{
        backgroundColor: color + '28',
        borderRadius: 4,
        paddingHorizontal: small ? 6 : 8,
        paddingVertical: small ? 2 : 4,
        alignSelf: 'flex-start',
      }}
    >
      <Text
        style={{
          fontSize: small ? 10 : 11,
          fontFamily: 'Sora_600SemiBold',
          color,
          letterSpacing: 0.3,
        }}
      >
        {category}
      </Text>
    </View>
  );
}
