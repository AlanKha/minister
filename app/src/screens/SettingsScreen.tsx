import { Feather } from '@expo/vector-icons';
import React, { useState } from 'react';
import { Alert, Modal, Pressable, ScrollView, Text, View } from 'react-native';
import { SectionCard } from '../components/SectionCard';
import { StatCard } from '../components/StatCard';
import { useStats } from '../hooks/useSettings';
import {
  useClearCategoryRules,
  useClearOverrides,
  useClearPins,
  useClearTransactions,
  useRecategorize,
  useResetCategoryRules,
  useUnlinkAccounts,
} from '../hooks/useSettings';
import { getBackupUrl } from '../api/apiClient';
import { AppColors } from '../theme/colors';
import { Linking } from 'react-native';

interface DangerAction {
  label: string;
  description: string;
  icon: keyof typeof Feather.glyphMap;
  color?: string;
  onConfirm: () => void;
}

export function SettingsScreen() {
  const { data: stats } = useStats();
  const { mutate: resetRules } = useResetCategoryRules();
  const { mutate: clearRules } = useClearCategoryRules();
  const { mutate: recategorize } = useRecategorize();
  const { mutate: clearOverrides } = useClearOverrides();
  const { mutate: clearPins } = useClearPins();
  const { mutate: clearTransactions } = useClearTransactions();
  const { mutate: unlinkAccounts } = useUnlinkAccounts();

  const [confirmModal, setConfirmModal] = useState<DangerAction | null>(null);

  function confirm(action: DangerAction) {
    setConfirmModal(action);
  }

  const dangerActions: DangerAction[] = [
    {
      label: 'Reset Category Rules',
      description: 'Restore default rules and re-categorize all transactions',
      icon: 'rotate-ccw',
      onConfirm: () => resetRules(),
    },
    {
      label: 'Re-categorize Transactions',
      description: 'Apply current rules to all transactions',
      icon: 'refresh-cw',
      onConfirm: () => recategorize(),
    },
    {
      label: 'Clear Category Rules',
      description: 'Delete all category rules',
      icon: 'trash',
      color: AppColors.negative,
      onConfirm: () => clearRules(),
    },
    {
      label: 'Clear Category Overrides',
      description: 'Remove all manual category assignments',
      icon: 'x-circle',
      color: AppColors.negative,
      onConfirm: () => clearOverrides(),
    },
    {
      label: 'Clear Pins',
      description: 'Remove all pinned transactions',
      icon: 'bookmark',
      onConfirm: () => clearPins(),
    },
    {
      label: 'Clear All Transactions',
      description: 'Permanently delete all transaction data',
      icon: 'alert-triangle',
      color: AppColors.negative,
      onConfirm: () => clearTransactions(),
    },
    {
      label: 'Unlink All Accounts',
      description: 'Remove all linked bank accounts',
      icon: 'link-2',
      color: AppColors.negative,
      onConfirm: () => unlinkAccounts(),
    },
  ];

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: AppColors.background }}
      contentContainerStyle={{ padding: 24, gap: 20 }}
    >
      <Text style={{ fontSize: 26, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary, letterSpacing: -0.5 }}>
        Settings
      </Text>

      {/* Stats */}
      {stats && (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 12 }}>
          <StatCard label="Transactions" value={String(stats.transactionCount)} />
          <StatCard label="Accounts" value={String(stats.accountCount)} />
          <StatCard label="Category Rules" value={String(stats.categoryRuleCount)} />
          <StatCard label="Uncategorized" value={String(stats.uncategorizedCount)} color={AppColors.warning} />
          <StatCard label="Pinned" value={String(stats.pinnedCount)} />
        </View>
      )}

      {/* Backup */}
      <SectionCard>
        <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 16 }}>
          Backup & Restore
        </Text>
        <Pressable
          onPress={() => Linking.openURL(getBackupUrl())}
          style={({ pressed }) => ({
            flexDirection: 'row',
            alignItems: 'center',
            gap: 10,
            paddingHorizontal: 16,
            paddingVertical: 12,
            borderRadius: 12,
            backgroundColor: pressed ? AppColors.accentSurface : AppColors.surfaceContainer,
            borderWidth: 1,
            borderColor: AppColors.border,
          })}
        >
          <Feather name="download" size={16} color={AppColors.accent} />
          <Text style={{ fontSize: 14, fontFamily: 'Sora_500Medium', color: AppColors.accent }}>
            Download Backup
          </Text>
        </Pressable>
      </SectionCard>

      {/* Danger zone */}
      <SectionCard>
        <Text style={{ fontSize: 16, fontFamily: 'Sora_600SemiBold', color: AppColors.textPrimary, marginBottom: 4 }}>
          Danger Zone
        </Text>
        <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginBottom: 16 }}>
          These actions may be irreversible
        </Text>
        <View style={{ gap: 8 }}>
          {dangerActions.map((action) => (
            <Pressable
              key={action.label}
              onPress={() => confirm(action)}
              style={({ pressed }) => ({
                flexDirection: 'row',
                alignItems: 'center',
                gap: 12,
                paddingHorizontal: 16,
                paddingVertical: 12,
                borderRadius: 12,
                backgroundColor: pressed ? (action.color ? action.color + '11' : AppColors.surfaceContainer) : AppColors.surfaceContainer,
                borderWidth: 1,
                borderColor: action.color ? action.color + '33' : AppColors.border,
              })}
            >
              <Feather name={action.icon} size={16} color={action.color ?? AppColors.textSecondary} />
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 14, fontFamily: 'Sora_500Medium', color: action.color ?? AppColors.textPrimary }}>
                  {action.label}
                </Text>
                <Text style={{ fontSize: 12, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 2 }}>
                  {action.description}
                </Text>
              </View>
              <Feather name="chevron-right" size={16} color={AppColors.textTertiary} />
            </Pressable>
          ))}
        </View>
      </SectionCard>

      {/* Confirm modal */}
      <Modal visible={!!confirmModal} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', alignItems: 'center', justifyContent: 'center' }}>
          {confirmModal && (
            <View
              style={{
                backgroundColor: AppColors.surface,
                borderRadius: 20,
                padding: 28,
                width: 380,
                maxWidth: '90%',
              }}
            >
              <Text style={{ fontSize: 18, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary, marginBottom: 10 }}>
                {confirmModal.label}
              </Text>
              <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textSecondary, marginBottom: 24, lineHeight: 22 }}>
                {confirmModal.description}. Are you sure?
              </Text>
              <View style={{ flexDirection: 'row', gap: 10 }}>
                <Pressable
                  onPress={() => setConfirmModal(null)}
                  style={({ pressed }) => ({
                    flex: 1,
                    paddingVertical: 12,
                    borderRadius: 12,
                    backgroundColor: AppColors.surfaceContainer,
                    opacity: pressed ? 0.8 : 1,
                    alignItems: 'center',
                  })}
                >
                  <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary }}>Cancel</Text>
                </Pressable>
                <Pressable
                  onPress={() => {
                    confirmModal.onConfirm();
                    setConfirmModal(null);
                  }}
                  style={({ pressed }) => ({
                    flex: 1,
                    paddingVertical: 12,
                    borderRadius: 12,
                    backgroundColor: confirmModal.color ?? AppColors.accent,
                    opacity: pressed ? 0.85 : 1,
                    alignItems: 'center',
                  })}
                >
                  <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: '#fff' }}>Confirm</Text>
                </Pressable>
              </View>
            </View>
          )}
        </View>
      </Modal>
    </ScrollView>
  );
}
