import React, { useEffect, useRef } from 'react';
import { Animated, View, ViewStyle } from 'react-native';
import { AppColors } from '../theme/colors';

interface SkeletonProps {
  width?: number | string;
  height?: number;
  borderRadius?: number;
  style?: ViewStyle;
}

export function Skeleton({ width = '100%', height = 16, borderRadius = 6, style }: SkeletonProps) {
  const opacity = useRef(new Animated.Value(0.3)).current;

  useEffect(() => {
    const anim = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, { toValue: 0.7, duration: 800, useNativeDriver: true }),
        Animated.timing(opacity, { toValue: 0.3, duration: 800, useNativeDriver: true }),
      ]),
    );
    anim.start();
    return () => anim.stop();
  }, [opacity]);

  return (
    <Animated.View
      style={[
        {
          width: width as number,
          height,
          borderRadius,
          backgroundColor: AppColors.surfaceContainer,
          opacity,
        },
        style,
      ]}
    />
  );
}

export function CardSkeleton() {
  return (
    <View
      style={{
        backgroundColor: AppColors.surface,
        borderRadius: 14,
        padding: 20,
        gap: 14,
        borderWidth: 1,
        borderColor: AppColors.border,
      }}
    >
      <Skeleton width={90} height={10} />
      <Skeleton width={160} height={30} />
      <Skeleton width="70%" height={10} />
    </View>
  );
}
