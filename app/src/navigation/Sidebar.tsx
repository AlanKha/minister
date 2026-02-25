import { DrawerContentComponentProps } from '@react-navigation/drawer';
import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { AppColors } from '../theme/colors';
import { useSyncStore } from '../stores/syncStore';
import { useSync } from '../hooks/useSync';

interface NavItem {
  label: string;
  screen: string;
  icon: keyof typeof Feather.glyphMap;
}

const NAV_ITEMS: NavItem[] = [
  { label: 'Overview', screen: 'Dashboard', icon: 'grid' },
  { label: 'Cash Flow', screen: 'CashFlow', icon: 'trending-up' },
  { label: 'Transactions', screen: 'Transactions', icon: 'list' },
  { label: 'Accounts', screen: 'Accounts', icon: 'credit-card' },
  { label: 'Balances', screen: 'Balances', icon: 'bar-chart-2' },
  { label: 'Categories', screen: 'Categories', icon: 'tag' },
  { label: 'Settings', screen: 'Settings', icon: 'settings' },
];

export function Sidebar({ state, navigation }: DrawerContentComponentProps) {
  const activeRoute = state.routes[state.index]?.name;
  const syncStatus = useSyncStore((s) => s.status);
  const { mutate: sync } = useSync();

  const syncLabel =
    syncStatus === 'syncing'
      ? 'Syncing…'
      : syncStatus === 'done'
      ? 'Synced!'
      : syncStatus === 'error'
      ? 'Error'
      : 'Sync';

  const syncColor =
    syncStatus === 'done'
      ? AppColors.positive
      : syncStatus === 'error'
      ? AppColors.negative
      : AppColors.accent;

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.sidebarBg, paddingTop: 32, paddingBottom: 24 }}>
      {/* Logo */}
      <View style={{ paddingHorizontal: 20, marginBottom: 32 }}>
        <View
          style={{
            width: 36,
            height: 36,
            borderRadius: 10,
            backgroundColor: AppColors.accent,
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 10,
          }}
        >
          <Text style={{ color: '#fff', fontFamily: 'Sora_700Bold', fontSize: 16 }}>M</Text>
        </View>
        <Text style={{ color: '#fff', fontFamily: 'Sora_700Bold', fontSize: 18, letterSpacing: -0.3 }}>
          minister
        </Text>
        <Text style={{ color: 'rgba(255,255,255,0.45)', fontFamily: 'Sora_400Regular', fontSize: 11 }}>
          finance
        </Text>
      </View>

      {/* Nav items */}
      <View style={{ flex: 1 }}>
        {NAV_ITEMS.map((item) => {
          const isActive = activeRoute === item.screen;
          return (
            <Pressable
              key={item.screen}
              onPress={() => navigation.navigate(item.screen)}
              style={({ pressed }) => ({
                flexDirection: 'row',
                alignItems: 'center',
                paddingHorizontal: 16,
                paddingVertical: 11,
                marginHorizontal: 8,
                marginVertical: 2,
                borderRadius: 10,
                backgroundColor: isActive
                  ? 'rgba(232,93,58,0.15)'
                  : pressed
                  ? AppColors.sidebarHover
                  : 'transparent',
              })}
            >
              {/* Active indicator */}
              <View
                style={{
                  width: 3,
                  height: 20,
                  borderRadius: 2,
                  backgroundColor: isActive ? AppColors.accent : 'transparent',
                  marginRight: 12,
                }}
              />
              <Feather
                name={item.icon}
                size={18}
                color={isActive ? AppColors.accent : 'rgba(255,255,255,0.55)'}
              />
              <Text
                style={{
                  marginLeft: 10,
                  fontFamily: isActive ? 'Sora_600SemiBold' : 'Sora_400Regular',
                  fontSize: 14,
                  color: isActive ? '#fff' : 'rgba(255,255,255,0.6)',
                }}
              >
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {/* Sync button */}
      <Pressable
        onPress={() => sync()}
        disabled={syncStatus === 'syncing'}
        style={({ pressed }) => ({
          flexDirection: 'row',
          alignItems: 'center',
          marginHorizontal: 16,
          marginTop: 12,
          paddingHorizontal: 16,
          paddingVertical: 12,
          borderRadius: 10,
          backgroundColor: pressed ? 'rgba(232,93,58,0.1)' : 'rgba(255,255,255,0.05)',
          borderWidth: 1,
          borderColor: 'rgba(255,255,255,0.1)',
          opacity: syncStatus === 'syncing' ? 0.6 : 1,
        })}
      >
        <Feather name="refresh-cw" size={16} color={syncColor} />
        <Text
          style={{
            marginLeft: 10,
            fontFamily: 'Sora_500Medium',
            fontSize: 13,
            color: syncColor,
          }}
        >
          {syncLabel}
        </Text>
      </Pressable>
    </View>
  );
}
