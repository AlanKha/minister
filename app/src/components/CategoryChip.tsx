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
        backgroundColor: color + '22',
        borderRadius: 20,
        paddingHorizontal: small ? 8 : 10,
        paddingVertical: small ? 3 : 5,
        alignSelf: 'flex-start',
      }}
    >
      <Text
        style={{
          fontSize: small ? 10 : 11,
          fontFamily: 'Sora_500Medium',
          color,
          letterSpacing: 0.2,
        }}
      >
        {category}
      </Text>
    </View>
  );
}
