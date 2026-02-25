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
import {
  useCategoryRules,
  useCreateCategoryRule,
  useDeleteCategoryRule,
  useImportDefaultRules,
  useUpdateCategoryRule,
} from '../hooks/useCategoryRules';
import { CategoryRule } from '../models/categoryRule';
import { AppColors, CATEGORIES, getCategoryColor } from '../theme/colors';

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

  function openCreate(category?: string) {
    setEditing(null);
    setForm(category ? { ...EMPTY_FORM, category } : EMPTY_FORM);
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
      { text: 'Delete', style: 'destructive', onPress: () => deleteRule(id) },
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

  // Group rules by category
  const grouped = (rules ?? []).reduce<Record<string, CategoryRule[]>>((acc, rule) => {
    (acc[rule.category] ??= []).push(rule);
    return acc;
  }, {});
  const sortedCategories = Object.keys(grouped).sort((a, b) => a.localeCompare(b));
  const totalRules = rules?.length ?? 0;

  return (
    <View style={{ flex: 1, backgroundColor: AppColors.background }}>
      <ScrollView contentContainerStyle={{ padding: 24, gap: 20 }}>
        {/* Header */}
        <View>
          <Text
            style={{
              fontSize: 10,
              fontFamily: 'Sora_600SemiBold',
              color: AppColors.accent,
              letterSpacing: 2,
              textTransform: 'uppercase',
              marginBottom: 8,
            }}
          >
            Rules
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between' }}>
            <View>
              <Text
                style={{
                  fontSize: 30,
                  fontFamily: 'Sora_700Bold',
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                }}
              >
                Categories
              </Text>
              {!isLoading && (
                <Text
                  style={{
                    fontSize: 13,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textTertiary,
                    marginTop: 4,
                  }}
                >
                  {totalRules} {totalRules === 1 ? 'rule' : 'rules'} across {sortedCategories.length}{' '}
                  {sortedCategories.length === 1 ? 'category' : 'categories'}
                </Text>
              )}
            </View>
            <View style={{ flexDirection: 'row', gap: 8, paddingBottom: 4 }}>
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
                <Text
                  style={{ fontSize: 12, fontFamily: 'Sora_500Medium', color: AppColors.textSecondary }}
                >
                  {importing ? 'Importing…' : 'Import Defaults'}
                </Text>
              </Pressable>
              <Pressable
                onPress={() => openCreate()}
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
                <Feather name="plus" size={14} color="#fff" />
                <Text style={{ fontSize: 12, fontFamily: 'Sora_600SemiBold', color: '#fff' }}>
                  New Rule
                </Text>
              </Pressable>
            </View>
          </View>
        </View>

        {/* Grouped rule list */}
        {isLoading ? (
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 16,
              padding: 20,
              borderWidth: 1,
              borderColor: AppColors.border,
            }}
          >
            <Text style={{ fontFamily: 'Sora_400Regular', color: AppColors.textTertiary }}>Loading…</Text>
          </View>
        ) : !rules?.length ? (
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 16,
              padding: 40,
              borderWidth: 1,
              borderColor: AppColors.border,
              alignItems: 'center',
            }}
          >
            <Feather name="tag" size={32} color={AppColors.textTertiary} />
            <Text
              style={{
                fontSize: 15,
                fontFamily: 'Sora_500Medium',
                color: AppColors.textSecondary,
                marginTop: 12,
              }}
            >
              No rules yet
            </Text>
            <Text
              style={{
                fontSize: 13,
                fontFamily: 'Sora_400Regular',
                color: AppColors.textTertiary,
                marginTop: 6,
                textAlign: 'center',
              }}
            >
              Create rules to automatically categorize transactions
            </Text>
          </View>
        ) : (
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 16,
              borderWidth: 1,
              borderColor: AppColors.border,
              overflow: 'hidden',
            }}
          >
            {sortedCategories.map((category, catIdx) => {
              const catRules = grouped[category];
              const color = getCategoryColor(category);
              return (
                <View key={category}>
                  {/* Category header */}
                  <View
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      paddingHorizontal: 16,
                      paddingVertical: 11,
                      backgroundColor: AppColors.surfaceContainer,
                      borderTopWidth: catIdx > 0 ? 1 : 0,
                      borderTopColor: AppColors.border,
                    }}
                  >
                    <View
                      style={{
                        width: 8,
                        height: 8,
                        borderRadius: 2,
                        backgroundColor: color,
                        marginRight: 10,
                      }}
                    />
                    <Text
                      style={{
                        fontSize: 12,
                        fontFamily: 'Sora_700Bold',
                        color,
                        letterSpacing: 0.5,
                        flex: 1,
                      }}
                    >
                      {category.toUpperCase()}
                    </Text>
                    <Text
                      style={{
                        fontSize: 11,
                        fontFamily: 'Sora_400Regular',
                        color: AppColors.textTertiary,
                        marginRight: 12,
                      }}
                    >
                      {catRules.length} {catRules.length === 1 ? 'rule' : 'rules'}
                    </Text>
                    <Pressable
                      onPress={() => openCreate(category)}
                      style={({ pressed }) => ({
                        padding: 4,
                        borderRadius: 6,
                        backgroundColor: pressed ? AppColors.surfaceHigh : 'transparent',
                      })}
                    >
                      <Feather name="plus" size={14} color={AppColors.textTertiary} />
                    </Pressable>
                  </View>

                  {/* Rules in this category */}
                  {catRules.map((rule, ruleIdx) => (
                    <View key={rule.id}>
                      <View
                        style={{
                          flexDirection: 'row',
                          alignItems: 'center',
                          paddingVertical: 12,
                          paddingLeft: 34,
                          paddingRight: 16,
                        }}
                      >
                        <View style={{ flex: 1 }}>
                          <Text
                            style={{
                              fontSize: 13,
                              fontFamily: 'Sora_400Regular',
                              color: AppColors.textPrimary,
                              fontVariant: ['tabular-nums'],
                            }}
                          >
                            {rule.pattern}
                          </Text>
                          {rule.caseSensitive && (
                            <Text
                              style={{
                                fontSize: 10,
                                fontFamily: 'Sora_400Regular',
                                color: AppColors.textTertiary,
                                marginTop: 2,
                              }}
                            >
                              case-sensitive
                            </Text>
                          )}
                        </View>
                        <View style={{ flexDirection: 'row', gap: 4 }}>
                          <Pressable
                            onPress={() => openEdit(rule)}
                            style={({ pressed }) => ({
                              padding: 8,
                              borderRadius: 8,
                              backgroundColor: pressed ? AppColors.surfaceContainer : 'transparent',
                            })}
                          >
                            <Feather name="edit-2" size={14} color={AppColors.textSecondary} />
                          </Pressable>
                          <Pressable
                            onPress={() => handleDelete(rule.id)}
                            style={({ pressed }) => ({
                              padding: 8,
                              borderRadius: 8,
                              backgroundColor: pressed ? AppColors.negativeLight : 'transparent',
                            })}
                          >
                            <Feather name="trash-2" size={14} color={AppColors.negative} />
                          </Pressable>
                        </View>
                      </View>
                      {ruleIdx < catRules.length - 1 && (
                        <View
                          style={{
                            height: 1,
                            backgroundColor: AppColors.borderSubtle,
                            marginLeft: 34,
                          }}
                        />
                      )}
                    </View>
                  ))}
                </View>
              );
            })}
          </View>
        )}
      </ScrollView>

      {/* Create/Edit Modal */}
      <Modal visible={modalVisible} transparent animationType="fade">
        <View
          style={{
            flex: 1,
            backgroundColor: 'rgba(0,0,0,0.6)',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <View
            style={{
              backgroundColor: AppColors.surface,
              borderRadius: 20,
              padding: 28,
              width: 480,
              maxWidth: '90%',
              borderWidth: 1,
              borderColor: AppColors.border,
            }}
          >
            <Text
              style={{
                fontSize: 18,
                fontFamily: 'Sora_700Bold',
                color: AppColors.textPrimary,
                marginBottom: 24,
              }}
            >
              {editing ? 'Edit Rule' : 'New Rule'}
            </Text>

            {/* Category picker */}
            <Text
              style={{
                fontSize: 10,
                fontFamily: 'Sora_600SemiBold',
                color: AppColors.textTertiary,
                letterSpacing: 1.4,
                textTransform: 'uppercase',
                marginBottom: 8,
              }}
            >
              Category
            </Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 20 }}>
              <View style={{ flexDirection: 'row', gap: 6 }}>
                {CATEGORIES.map((cat) => {
                  const catColor = getCategoryColor(cat);
                  const isSelected = form.category === cat;
                  return (
                    <Pressable
                      key={cat}
                      onPress={() => setForm((f) => ({ ...f, category: cat }))}
                      style={{
                        paddingHorizontal: 12,
                        paddingVertical: 6,
                        borderRadius: 6,
                        backgroundColor: isSelected ? catColor + '28' : AppColors.surfaceContainer,
                        borderWidth: 1,
                        borderColor: isSelected ? catColor : 'transparent',
                      }}
                    >
                      <Text
                        style={{
                          fontSize: 12,
                          fontFamily: 'Sora_500Medium',
                          color: isSelected ? catColor : AppColors.textSecondary,
                        }}
                      >
                        {cat}
                      </Text>
                    </Pressable>
                  );
                })}
              </View>
            </ScrollView>

            {/* Pattern */}
            <Text
              style={{
                fontSize: 10,
                fontFamily: 'Sora_600SemiBold',
                color: AppColors.textTertiary,
                letterSpacing: 1.4,
                textTransform: 'uppercase',
                marginBottom: 8,
              }}
            >
              Regex Pattern
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
                backgroundColor: AppColors.surfaceContainer,
                marginBottom: 16,
              }}
            />

            {/* Case sensitive */}
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 20,
              }}
            >
              <View>
                <Text
                  style={{ fontSize: 14, fontFamily: 'Sora_400Regular', color: AppColors.textPrimary }}
                >
                  Case sensitive
                </Text>
                <Text
                  style={{
                    fontSize: 12,
                    fontFamily: 'Sora_400Regular',
                    color: AppColors.textTertiary,
                    marginTop: 2,
                  }}
                >
                  Match uppercase and lowercase exactly
                </Text>
              </View>
              <Switch
                value={form.caseSensitive}
                onValueChange={(v) => setForm((f) => ({ ...f, caseSensitive: v }))}
                trackColor={{ true: AppColors.accent }}
              />
            </View>

            {/* Test */}
            <Text
              style={{
                fontSize: 10,
                fontFamily: 'Sora_600SemiBold',
                color: AppColors.textTertiary,
                letterSpacing: 1.4,
                textTransform: 'uppercase',
                marginBottom: 8,
              }}
            >
              Test (optional)
            </Text>
            <TextInput
              value={testInput}
              onChangeText={setTestInput}
              placeholder="Type a transaction description to test…"
              placeholderTextColor={AppColors.textTertiary}
              style={{
                borderWidth: 1,
                borderColor:
                  testResult === true
                    ? AppColors.positive
                    : testResult === false
                    ? AppColors.negative
                    : AppColors.border,
                borderRadius: 10,
                paddingHorizontal: 14,
                paddingVertical: 10,
                fontSize: 14,
                fontFamily: 'Sora_400Regular',
                color: AppColors.textPrimary,
                backgroundColor: AppColors.surfaceContainer,
                marginBottom: 6,
              }}
            />
            {testResult !== null && (
              <Text
                style={{
                  fontSize: 12,
                  fontFamily: 'Sora_600SemiBold',
                  color: testResult ? AppColors.positive : AppColors.negative,
                  marginBottom: 20,
                }}
              >
                {testResult ? '✓ Matches' : '✗ No match'}
              </Text>
            )}

            {/* Actions */}
            <View style={{ flexDirection: 'row', gap: 10, marginTop: testResult !== null ? 0 : 14 }}>
              <Pressable
                onPress={() => setModalVisible(false)}
                style={({ pressed }) => ({
                  flex: 1,
                  paddingVertical: 12,
                  borderRadius: 12,
                  backgroundColor: pressed ? AppColors.surfaceHigh : AppColors.surfaceContainer,
                  alignItems: 'center',
                  borderWidth: 1,
                  borderColor: AppColors.border,
                })}
              >
                <Text
                  style={{ fontSize: 14, fontFamily: 'Sora_600SemiBold', color: AppColors.textSecondary }}
                >
                  Cancel
                </Text>
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
