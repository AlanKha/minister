import { Feather } from '@expo/vector-icons';
import React from 'react';
import { ActivityIndicator, Pressable, Text } from 'react-native';
import { useSync } from '../hooks/useSync';
import { useSyncStore } from '../stores/syncStore';
import { AppColors } from '../theme/colors';

export function SyncButton() {
  const { mutate: sync } = useSync();
  const status = useSyncStore((s) => s.status);

  const isSyncing = status === 'syncing';
  const label =
    status === 'syncing' ? 'Syncing…' : status === 'done' ? 'Synced!' : status === 'error' ? 'Error' : 'Sync';
  const color =
    status === 'done' ? AppColors.positive : status === 'error' ? AppColors.negative : AppColors.accent;

  return (
    <Pressable
      onPress={() => sync()}
      disabled={isSyncing}
      style={({ pressed }) => ({
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
        paddingHorizontal: 14,
        paddingVertical: 8,
        borderRadius: 10,
        backgroundColor: pressed ? AppColors.accentSurface : AppColors.surface,
        borderWidth: 1,
        borderColor: color + '44',
        opacity: isSyncing ? 0.7 : 1,
      })}
    >
      {isSyncing ? (
        <ActivityIndicator size="small" color={color} />
      ) : (
        <Feather name="refresh-cw" size={14} color={color} />
      )}
      <Text style={{ fontSize: 13, fontFamily: 'Sora_500Medium', color }}>{label}</Text>
    </Pressable>
  );
}
