import 'store/json_store.dart';

// Load default rules from JSON file (user-customizable, gitignored)
List<MapEntry<RegExp, String>> _loadDefaultCategoryRules() {
  final defaultRules = loadDefaultCategoryRules();
  return defaultRules.map((r) => MapEntry(r.toRegExp(), r.category)).toList();
}

// Combine default rules with user-defined rules from persistent storage
// User-defined rules take precedence by coming first
List<MapEntry<RegExp, String>> getCategoryRules() {
  final userRules = loadCategoryRules();
  final userEntries = userRules.map((r) => MapEntry(r.toRegExp(), r.category)).toList();
  final defaultRules = _loadDefaultCategoryRules();

  // User rules take precedence by coming first
  return [...userEntries, ...defaultRules];
}

// For backward compatibility, expose as categoryRules
List<MapEntry<RegExp, String>> get categoryRules => getCategoryRules();
