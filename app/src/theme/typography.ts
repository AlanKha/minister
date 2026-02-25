import { TextStyle } from 'react-native';

export const Typography: Record<string, TextStyle> = {
  displayLarge: { fontSize: 32, fontFamily: 'Sora_700Bold', letterSpacing: -0.5 },
  displayMedium: { fontSize: 24, fontFamily: 'Sora_700Bold', letterSpacing: -0.3 },
  headingLarge: { fontSize: 20, fontFamily: 'Sora_600SemiBold', letterSpacing: -0.2 },
  headingMedium: { fontSize: 16, fontFamily: 'Sora_600SemiBold' },
  headingSmall: { fontSize: 14, fontFamily: 'Sora_600SemiBold' },
  bodyLarge: { fontSize: 16, fontFamily: 'Sora_400Regular' },
  bodyMedium: { fontSize: 14, fontFamily: 'Sora_400Regular' },
  bodySmall: { fontSize: 12, fontFamily: 'Sora_400Regular' },
  labelMedium: { fontSize: 12, fontFamily: 'Sora_500Medium', letterSpacing: 0.3 },
  labelSmall: { fontSize: 11, fontFamily: 'Sora_500Medium', letterSpacing: 0.5 },
  mono: { fontSize: 14, fontFamily: 'Sora_400Regular' },
};
