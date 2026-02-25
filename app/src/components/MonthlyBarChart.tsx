import React from 'react';
import { ScrollView, Text, View } from 'react-native';
import { MonthlyBreakdown } from '../models/analytics';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { formatMonth } from '../utils/date';

interface MonthlyBarChartProps {
  data: MonthlyBreakdown[];
}

export function MonthlyBarChart({ data }: MonthlyBarChartProps) {
  if (data.length === 0) {
    return (
      <View style={{ alignItems: 'center', paddingVertical: 32 }}>
        <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
          No data
        </Text>
      </View>
    );
  }

  const maxVal = Math.max(...data.map((d) => Math.abs(d.totalCents)));
  const chartHeight = 160;

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false}>
      <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 8, paddingBottom: 24 }}>
        {data.map((item) => {
          const pct = maxVal > 0 ? Math.abs(item.totalCents) / maxVal : 0;
          const barH = Math.max(4, chartHeight * pct);
          return (
            <View key={item.month} style={{ alignItems: 'center', width: 48 }}>
              <Text
                style={{
                  fontSize: 10,
                  fontFamily: 'Sora_400Regular',
                  color: AppColors.textTertiary,
                  marginBottom: 4,
                }}
                numberOfLines={1}
              >
                {formatCents(item.totalCents)}
              </Text>
              <View
                style={{
                  width: 36,
                  height: barH,
                  backgroundColor: AppColors.accent,
                  borderRadius: 6,
                  opacity: 0.85,
                }}
              />
              <Text
                style={{
                  fontSize: 10,
                  fontFamily: 'Sora_400Regular',
                  color: AppColors.textSecondary,
                  marginTop: 6,
                  textAlign: 'center',
                }}
                numberOfLines={1}
              >
                {formatMonth(item.month).replace(' 20', "'")}
              </Text>
            </View>
          );
        })}
      </View>
    </ScrollView>
  );
}
