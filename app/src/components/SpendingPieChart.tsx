import React from 'react';
import { Text, View } from 'react-native';
import { CategoryBreakdown } from '../models/analytics';
import { AppColors, getCategoryColor } from '../theme/colors';
import { formatCents } from '../utils/currency';

interface SpendingPieChartProps {
  data: CategoryBreakdown[];
  size?: number;
}

// Simple pie chart using SVG-like approach with colored legend
// Victory Native requires native linking; we use a simple visual representation
export function SpendingPieChart({ data, size = 200 }: SpendingPieChartProps) {
  const total = data.reduce((sum, d) => sum + Math.abs(d.totalCents), 0);
  const topCategories = [...data]
    .sort((a, b) => Math.abs(b.totalCents) - Math.abs(a.totalCents))
    .slice(0, 8);

  if (data.length === 0) {
    return (
      <View style={{ alignItems: 'center', justifyContent: 'center', height: size }}>
        <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
          No data
        </Text>
      </View>
    );
  }

  return (
    <View style={{ gap: 8 }}>
      {topCategories.map((item) => {
        const pct = total > 0 ? (Math.abs(item.totalCents) / total) * 100 : 0;
        const color = getCategoryColor(item.category);
        return (
          <View key={item.category} style={{ gap: 4 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: color }} />
                <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textPrimary }}>
                  {item.category}
                </Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <Text style={{ fontSize: 12, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
                  {pct.toFixed(1)}%
                </Text>
                <Text style={{ fontSize: 13, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, minWidth: 80, textAlign: 'right' }}>
                  {formatCents(item.totalCents)}
                </Text>
              </View>
            </View>
            {/* Bar */}
            <View style={{ height: 4, backgroundColor: AppColors.surfaceContainer, borderRadius: 2 }}>
              <View
                style={{
                  height: 4,
                  width: `${pct}%`,
                  backgroundColor: color,
                  borderRadius: 2,
                }}
              />
            </View>
          </View>
        );
      })}
    </View>
  );
}
