import React from 'react';
import { ScrollView, Text, View } from 'react-native';
import { WeeklyBreakdown } from '../models/analytics';
import { AppColors } from '../theme/colors';
import { formatCents } from '../utils/currency';
import { formatWeek } from '../utils/date';

interface WeeklyBarChartProps {
  data: WeeklyBreakdown[];
}

export function WeeklyBarChart({ data }: WeeklyBarChartProps) {
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
  const chartHeight = 140;

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false}>
      <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 6, paddingBottom: 24 }}>
        {data.map((item) => {
          const pct = maxVal > 0 ? Math.abs(item.totalCents) / maxVal : 0;
          const barH = Math.max(4, chartHeight * pct);
          return (
            <View key={item.weekStart} style={{ alignItems: 'center', width: 44 }}>
              <Text
                style={{
                  fontSize: 9,
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
                  width: 32,
                  height: barH,
                  backgroundColor: AppColors.accentLight,
                  borderRadius: 5,
                  opacity: 0.9,
                }}
              />
              <Text
                style={{
                  fontSize: 9,
                  fontFamily: 'Sora_400Regular',
                  color: AppColors.textSecondary,
                  marginTop: 5,
                  textAlign: 'center',
                }}
              >
                {formatWeek(item.weekStart)}
              </Text>
            </View>
          );
        })}
      </View>
    </ScrollView>
  );
}
