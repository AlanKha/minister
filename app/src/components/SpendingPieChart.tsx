import React from 'react';
import { Text, View } from 'react-native';
import { CategoryBreakdown } from '../models/analytics';
import { AppColors, getCategoryColor } from '../theme/colors';
import { formatCents } from '../utils/currency';

interface SpendingPieChartProps {
  data: CategoryBreakdown[];
  size?: number;
}

export function SpendingPieChart({ data, size = 200 }: SpendingPieChartProps) {
  const total = data.reduce((sum, d) => sum + Math.abs(d.totalCents), 0);
  const topCategories = [...data]
    .sort((a, b) => Math.abs(b.totalCents) - Math.abs(a.totalCents))
    .slice(0, 8);

  if (data.length === 0) {
    return (
      <View style={{ alignItems: 'center', justifyContent: 'center', paddingVertical: 32 }}>
        <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
          No spending data
        </Text>
      </View>
    );
  }

  return (
    <View style={{ gap: 12 }}>
      {topCategories.map((item) => {
        const pct = total > 0 ? (Math.abs(item.totalCents) / total) * 100 : 0;
        const color = getCategoryColor(item.category);
        return (
          <View key={item.category} style={{ gap: 7 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <Text
                style={{
                  fontSize: 12,
                  fontFamily: 'Sora_500Medium',
                  color,
                  flex: 1,
                }}
              >
                {item.category}
              </Text>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <Text
                  style={{
                    fontSize: 11,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textTertiary,
                    minWidth: 36,
                    textAlign: 'right',
                  }}
                >
                  {pct.toFixed(0)}%
                </Text>
                <Text
                  style={{
                    fontSize: 13,
                    fontFamily: 'Sora_700Bold',
                    color: AppColors.textPrimary,
                    minWidth: 72,
                    textAlign: 'right',
                    letterSpacing: -0.3,
                  }}
                >
                  {formatCents(item.totalCents)}
                </Text>
              </View>
            </View>
            {/* Bar track */}
            <View
              style={{
                height: 5,
                backgroundColor: AppColors.surfaceContainer,
                borderRadius: 3,
              }}
            >
              <View
                style={{
                  height: 5,
                  width: `${pct}%`,
                  backgroundColor: color,
                  borderRadius: 3,
                  opacity: 0.9,
                }}
              />
            </View>
          </View>
        );
      })}
    </View>
  );
}
