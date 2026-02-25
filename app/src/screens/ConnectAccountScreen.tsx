import React from 'react';
import { Text, View } from 'react-native';
import { AppColors } from '../theme/colors';

// WebView for OAuth/Plaid flow - requires react-native-webview
// For now, show a placeholder since react-native-webview needs native linking
export function ConnectAccountScreen() {
  const connectUrl = 'http://localhost:3000/connect';

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.background, alignItems: 'center', justifyContent: 'center' }}>
      <Text style={{ fontSize: 16, fontFamily: 'Sora_400Regular', color: AppColors.textSecondary }}>
        Open {connectUrl} in your browser to connect an account.
      </Text>
    </View>
  );
}
