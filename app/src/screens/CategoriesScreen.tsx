import { Feather } from '@expo/vector-icons';
import React, { useState } from 'react';
import {
  Alert,
  Modal,
  Pressable,
  ScrollView,
  Switch,
  Text,
  TextInput,
  View,
} from 'react-native';
import { SectionCard } from '../components/SectionCard';
import {
  useCategoryRules,
  useCreateCategoryRule,
  useDeleteCategoryRule,
  useImportDefaultRules,
  useUpdateCategoryRule,
} from '../hooks/useCategoryRules';
import { CategoryRule } from '../models/categoryRule';
import { AppColors, CATEGORIES } from '../theme/colors';

interface RuleFormState {
  category: string;
  pattern: string;
  caseSensitive: boolean;
}

const EMPTY_FORM: RuleFormState = { category: CATEGORIES[0], pattern: '', caseSensitive: false };

export function CategoriesScreen() {
  const { data: rules, isLoading } = useCategoryRules();
  const { mutate: createRule } = useCreateCategoryRule();
  const { mutate: updateRule } = useUpdateCategoryRule();
  const { mutate: deleteRule } = useDeleteCategoryRule();
  const { mutate: importDefaults, isPending: importing } = useImportDefaultRules();

  const [modalVisible, setModalVisible] = useState(false);
  const [editing, setEditing] = useState<CategoryRule | null>(null);
  const [form, setForm] = useState<RuleFormState>(EMPTY_FORM);
  const [testInput, setTestInput] = useState('');

  function openCreate() {
    setEditing(null);
    setForm(EMPTY_FORM);
    setTestInput('');
    setModalVisible(true);
  }

  function openEdit(rule: CategoryRule) {
    setEditing(rule);
    setForm({ category: rule.category, pattern: rule.pattern, caseSensitive: rule.caseSensitive });
    setTestInput('');
    setModalVisible(true);
  }

  function handleSave() {
    if (!form.pattern.trim()) return;
    if (editing) {
      updateRule({ id: editing.id, rule: form });
    } else {
      createRule(form);
    }
    setModalVisible(false);
  }

  function handleDelete(id: string) {
    Alert.alert('Delete Rule', 'Are you sure you want to delete this rule?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: () => deleteRule(id),
      },
    ]);
  }

  let testResult: boolean | null = null;
  if (testInput && form.pattern) {
    try {
      const flags = form.caseSensitive ? '' : 'i';
      testResult = new RegExp(form.pattern, flags).test(testInput);
    } catch {
      testResult = null;
    }
  }

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.background }}>
      <ScrollView contentContainerStyle={{ padding: 24, gap: 20 }}>
        {/* Header */}
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <Text style={{ fontSize: 26, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary, letterSpacing: -0.5 }}>
            Categories
          </Text>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Pressable
              onPress={() => importDefaults()}
              disabled={importing}
              style={({ pressed }) => ({
                paddingHorizontal: 14,
                paddingVertical: 8,
                borderRadius: 10,
                backgroundColor: pressed ? AppColors.surfaceContainer : AppColors.surface,
                borderWidth: 1,
                borderColor: AppColors.border,
              })}
            >
              <Text style={{ fontSize: 13, fontFamily: 'Sora_500Medium', color: AppColors.textSecondary }}>
                {importing ? 'Importing…' : 'Import Defaults'}
              </Text>
            </Pressable>
            <Pressable
              onPress={openCreate}
              style={({ pressed }) => ({
                paddingHorizontal: 14,
                paddingVertical: 8,
                borderRadius: 10,
                backgroundColor: AppColors.accent,
                opacity: pressed ? 0.85 : 1,
                flexDirection: 'row',
                alignItems: 'center',
                gap: 6,
              })}
            >
              <Feather name="plus" size={16} color="#fff" />
              <Text style={{ fontSize: 13, fontFamily: 'Sora_600SemiBold', color: '#fff' }}>New Rule</Text>
            </Pressable>
          </View>
        </View>

        {/* Rule list */}
        <SectionCard style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
          {isLoading ? (
            <View style={{ padding: 20 }}>
              <Text style={{ fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>Loading…</Text>
            </View>
          ) : !rules?.length ? (
            <View style={{ padding: 40, alignItems: 'center' }}>
              <Feather name="tag" size={32} color={AppColors.textTertiary} />
              <Text style={{ fontSize: 15, fontFamily: 'Sora_500Medium', color: AppColors.textSecondary, marginTop: 12 }}>
                No rules yet
              </Text>
              <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary, marginTop: 6, textAlign: 'center' }}>
                Create rules to auto-categorize transactions
              </Text>
            </View>
          ) : (
            rules.map((rule, i) => (
              <View key={rule.id}>
                <View style={{ flexDirection: 'row', alignItems: 'center', padding: 16 }}>
                  <View style={{ flex: 1 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                      <View
                        style={{
                          paddingHorizontal: 8,
                          paddingVertical: 3,
                          borderRadius: 12,
                          backgroundColor: AppColors.accentSurface,
                        }}
                      >
                        <Text style={{ fontSize: 11, fontFamily: 'Sora_600SemiBold', color: AppColors.accent }}>
                          {rule.category}
                        </Text>
                      </View>
                      {rule.caseSensitive && (
                        <Text style={{ fontSize: 10, fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>
                          case-sensitive
                        </Text>
                      )}
                    </View>
                    <Text style={{ fontSize: 13, fontFamily: 'Sora_400Regular', color: AppColors.textSecondary }}>
                      {rule.pattern}
                    </Text>
                  </View>
                  <View style={{ flexDirection: 'row', gap: 8 }}>
                    <Pressable onPress={() => openEdit(rule)} style={{ padding: 8, borderRadius: 8 }}>
                      <Feather name="edit-2" size={15} color={AppColors.textSecondary} />
                    </Pressable>
                    <Pressable onPress={() => handleDelete(rule.id)} style={{ padding: 8, borderRadius: 8 }}>
                      <Feather name="trash-2" size={15} color={AppColors.negative} />
                    </Pressable>
                  </View>
                </View>
                {i < rules.length - 1 && (
                  <View style={{ height: 1, backgroundColor: AppColors.borderSubtle, marginHorizontal: 16 }} />
                )}
              </View>
            ))
          )}
        </SectionCard>
      </ScrollView>

      {/* Create/Edit Modal */}
      <Modal visible={modalVisible} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', alignItems: 'center', justifyContent: 'center' }}>
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 20,
              padding: 28,
              width: 480,
              maxWidth: '90%',
            }}
          >
            <Text style={{ fontSize: 18, fontFamily: 'Sora_700Bold', color: AppColors.textPrimary, marginBottom: 20 }}>
              {editing ? 'Edit Rule' : 'New Rule'}
            </Text>

            {/* Category */}
            <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary, marginBottom: 6, letterSpacing: 0.3 }}>
              CATEGORY
            </Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 16 }}>
              <View style={{ flexDirection: 'row', gap: 6 }}>
                {CATEGORIES.map((cat) => (
                  <Pressable
                    key={cat}
                    onPress={() => setForm((f) => ({ ...f, category: cat }))}
                    style={{
                      paddingHorizontal: 12,
                      paddingVertical: 6,
                      borderRadius: 16,
                      backgroundColor: form.category === cat ? AppColors.accent : AppColors.surfaceContainer,
                    }}
                  >
                    <Text
                      style={{
                        fontSize: 12,
                        fontFamily: 'Sora_500Medium',
                        color: form.category === cat ? '#fff' : AppColors.textSecondary,
                      }}
                    >
                      {cat}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </ScrollView>

            {/* Pattern */}
            <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary, marginBottom: 6, letterSpacing: 0.3 }}>
              REGEX PATTERN
            </Text>
            <TextInput
              value={form.pattern}
              onChangeText={(v) => setForm((f) => ({ ...f, pattern: v }))}
              placeholder="e.g. McDonald|Burger King"
              placeholderTextColor={AppColors.textTertiary}
              style={{
                borderWidth: 1,
                borderColor: AppColors.border,
                borderRadius: 10,
                paddingHorizontal: 14,
                paddingVertical: 10,
                fontSize: 14,
                fontFamily: 'Sora_400Regular',
                color: AppColors.textPrimary,
                marginBottom: 12,
              }}
            />

            {/* Case sensitive */}
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
              <Text style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textPrimary }}>Case sensitive</Text>
              <Switch
                value={form.caseSensitive}
                onValueChange={(v) => setForm((f) => ({ ...f, caseSensitive: v }))}
                trackColor={{ true: AppColors.accent }}
              />
            </View>

            {/* Test input */}
            <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary, marginBottom: 6, letterSpacing: 0.3 }}>
              TEST (optional)
            </Text>
            <TextInput
              value={testInput}
              onChangeText={setTestInput}
              placeholder="Type a transaction description…"
              placeholderTextColor={AppColors.textTertiary}
              style={{
                borderWidth: 1,
                borderColor: testResult === true ? AppColors.positive : testResult === false ? AppColors.negative : AppColors.border,
                borderRadius: 10,
                paddingHorizontal: 14,
                paddingVertical: 10,
                fontSize: 14,
                fontFamily: 'Sora_400Regular',
                color: AppColors.textPrimary,
                marginBottom: 4,
              }}
            />
            {testResult !== null && (
              <Text style={{ fontSize: 12, fontFamily: 'Sora_500Medium', color: testResult ? AppColors.positive : AppColors.negative, marginBottom: 16 }}>
                {testResult ? '✓ Matches' : '✗ No match'}
              </Text>
            )}

            {/* Actions */}
            <View style={{ flexDirection: 'row', gap: 10, marginTop: 8 }}>
              <Pressable
                onPress={() => setModalVisible(false)}
                style={({ pressed }) => ({
                  flex: 1,
                  paddingVertical: 12,
                  borderRadius: 12,
                  backgroundColor: pressed ? AppColors.surfaceContainer : AppColors.surfaceContainer,
                  alignItems: 'center',
                })}
              >
                <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary }}>Cancel</Text>
              </Pressable>
              <Pressable
                onPress={handleSave}
                style={({ pressed }) => ({
                  flex: 1,
                  paddingVertical: 12,
                  borderRadius: 12,
                  backgroundColor: AppColors.accent,
                  opacity: pressed ? 0.85 : 1,
                  alignItems: 'center',
                })}
              >
                <Text style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: '#fff' }}>
                  {editing ? 'Update' : 'Create'}
                </Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}
