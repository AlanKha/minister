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
      : AppColors.textTertiary;

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.sidebarBg, paddingTop: 32, paddingBottom: 24 }}>
      {/* Logo */}
      <View style={{ paddingHorizontal: 22, marginBottom: 28, flexDirection: 'row', alignItems: 'center', gap: 12 }}>
        <View
          style={{
            width: 30,
            height: 30,
            borderRadius: 8,
            backgroundColor: AppColors.accent,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Text style={{ color: '#fff', fontFamily: 'Sora_700Bold', fontSize: 14, letterSpacing: -0.5 }}>M</Text>
        </View>
        <View>
          <Text style={{ color: AppColors.sidebarText, fontFamily: 'Sora_700Bold', fontSize: 14, letterSpacing: -0.3 }}>
            minister
          </Text>
          <Text
            style={{
              color: 'rgba(242,242,248,0.28)',
              fontFamily: 'Sora_400Regular',
              fontSize: 9,
              letterSpacing: 1.8,
              textTransform: 'uppercase',
              marginTop: 1,
            }}
          >
            finance
          </Text>
        </View>
      </View>

      {/* Separator */}
      <View style={{ height: 1, backgroundColor: 'rgba(255,255,255,0.05)', marginBottom: 12 }} />

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
                paddingHorizontal: 22,
                paddingVertical: 11,
                position: 'relative',
                backgroundColor: isActive
                  ? 'rgba(255,92,56,0.07)'
                  : pressed
                  ? 'rgba(255,255,255,0.03)'
                  : 'transparent',
              })}
            >
              {/* Active left indicator */}
              {isActive && (
                <View
                  style={{
                    position: 'absolute',
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 2,
                    backgroundColor: AppColors.accent,
                  }}
                />
              )}
              <Feather
                name={item.icon}
                size={15}
                color={isActive ? AppColors.accent : 'rgba(242,242,248,0.32)'}
              />
              <Text
                style={{
                  marginLeft: 11,
                  fontFamily: isActive ? 'Sora_600SemiBold' : 'Sora_400Regular',
                  fontSize: 13,
                  color: isActive ? AppColors.sidebarText : 'rgba(242,242,248,0.48)',
                  letterSpacing: 0.1,
                }}
              >
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {/* Separator */}
      <View style={{ height: 1, backgroundColor: 'rgba(255,255,255,0.05)', marginBottom: 14 }} />

      {/* Sync button */}
      <Pressable
        onPress={() => sync()}
        disabled={syncStatus === 'syncing'}
        style={({ pressed }) => ({
          flexDirection: 'row',
          alignItems: 'center',
          marginHorizontal: 14,
          paddingHorizontal: 14,
          paddingVertical: 10,
          borderRadius: 8,
          backgroundColor: pressed ? 'rgba(255,255,255,0.05)' : 'transparent',
          opacity: syncStatus === 'syncing' ? 0.5 : 1,
        })}
      >
        <Feather name="refresh-cw" size={13} color={syncColor} />
        <Text
          style={{
            marginLeft: 9,
            fontFamily: 'Sora_500Medium',
            fontSize: 12,
            color: syncColor,
            letterSpacing: 0.2,
          }}
        >
          {syncLabel}
        </Text>
      </Pressable>
    </View>
  );
}
