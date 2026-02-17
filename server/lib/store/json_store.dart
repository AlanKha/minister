import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:minister_shared/models/account.dart';
import 'package:minister_shared/models/transaction.dart';

late final String dataDir;
late final String serverRoot;

void initStore(String root) {
  serverRoot = root;
  dataDir = p.join(serverRoot, 'data');
  Directory(dataDir).createSync(recursive: true);
}

String get _accountFile => p.join(dataDir, 'linked_account.json');
String get _txFile => p.join(dataDir, 'transactions.json');
String get _cleanFile => p.join(dataDir, 'transactions_clean.json');
String get _overridesFile => p.join(dataDir, 'category_overrides.json');
String get _categoryRulesFile => p.join(dataDir, 'category_rules.json');
String get _balancesFile => p.join(dataDir, 'balances.json');
String get _pinnedTransactionsFile => p.join(dataDir, 'pinned_transactions.json');
String get _deletedDefaultsFile => p.join(dataDir, 'deleted_defaults.json');
String get _defaultCategoryRulesFile => p.join(serverRoot, 'default_category_rules.json');
String get _exampleDefaultCategoryRulesFile => p.join(serverRoot, 'example_default_category_rules.json');

AccountData readAccountData() {
  try {
    final content = File(_accountFile).readAsStringSync();
    return AccountData.fromJson(jsonDecode(content) as Map<String, dynamic>);
  } catch (_) {
    return AccountData();
  }
}

void writeAccountData(AccountData data) {
  Directory(dataDir).createSync(recursive: true);
  File(_accountFile).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(data.toJson()));
}

List<StoredTransaction> loadTransactions() {
  try {
    final content = File(_txFile).readAsStringSync();
    return (jsonDecode(content) as List<dynamic>)
        .map((e) => StoredTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

void saveTransactions(List<StoredTransaction> transactions) {
  Directory(dataDir).createSync(recursive: true);
  File(_txFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ')
        .convert(transactions.map((t) => t.toJson()).toList()),
  );
}

List<CleanTransaction> loadCleanTransactions() {
  try {
    final content = File(_cleanFile).readAsStringSync();
    return (jsonDecode(content) as List<dynamic>)
        .map((e) => CleanTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

void saveCleanTransactions(List<CleanTransaction> transactions) {
  Directory(dataDir).createSync(recursive: true);
  File(_cleanFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ')
        .convert(transactions.map((t) => t.toJson()).toList()),
  );
}

Map<String, String> loadOverrides() {
  try {
    final content = File(_overridesFile).readAsStringSync();
    return (jsonDecode(content) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
  } catch (_) {
    return {};
  }
}

void saveOverrides(Map<String, String> overrides) {
  Directory(dataDir).createSync(recursive: true);
  File(_overridesFile)
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(overrides));
}

Set<String> loadPinnedTransactions() {
  try {
    final content = File(_pinnedTransactionsFile).readAsStringSync();
    return (jsonDecode(content) as List<dynamic>).cast<String>().toSet();
  } catch (_) {
    return {};
  }
}

void savePinnedTransactions(Set<String> pinned) {
  Directory(dataDir).createSync(recursive: true);
  File(_pinnedTransactionsFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(pinned.toList()),
  );
}

String accountLabel(LinkedAccount acct) {
  return [
    acct.institution,
    acct.displayName,
    acct.last4 != null ? '****${acct.last4}' : null
  ].where((s) => s != null && s.isNotEmpty).join(' ');
}

class CategoryRule {
  final String id;
  final String category;
  final String pattern;
  final bool caseSensitive;

  CategoryRule({
    required this.id,
    required this.category,
    required this.pattern,
    this.caseSensitive = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'pattern': pattern,
        'caseSensitive': caseSensitive,
      };

  factory CategoryRule.fromJson(Map<String, dynamic> json) => CategoryRule(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        category: json['category'] as String,
        pattern: json['pattern'] as String,
        caseSensitive: json['caseSensitive'] as bool? ?? false,
      );

  RegExp toRegExp() => RegExp(pattern, caseSensitive: caseSensitive);
}

List<CategoryRule> loadCategoryRules() {
  try {
    final content = File(_categoryRulesFile).readAsStringSync();
    return (jsonDecode(content) as List<dynamic>)
        .map((e) => CategoryRule.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

void saveCategoryRules(List<CategoryRule> rules) {
  Directory(dataDir).createSync(recursive: true);
  File(_categoryRulesFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ')
        .convert(rules.map((r) => r.toJson()).toList()),
  );
}

Map<String, dynamic> loadBalances() {
  try {
    final content = File(_balancesFile).readAsStringSync();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

void saveBalances(Map<String, dynamic> balances) {
  Directory(dataDir).createSync(recursive: true);
  File(_balancesFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(balances),
  );
}

Set<String> loadDeletedDefaults() {
  try {
    final content = File(_deletedDefaultsFile).readAsStringSync();
    return (jsonDecode(content) as List<dynamic>).cast<String>().toSet();
  } catch (_) {
    return {};
  }
}

void saveDeletedDefaults(Set<String> deletedDefaults) {
  Directory(dataDir).createSync(recursive: true);
  File(_deletedDefaultsFile).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(deletedDefaults.toList()),
  );
}

List<CategoryRule> loadDefaultCategoryRules() {
  // Initialize default_category_rules.json from example if it doesn't exist
  final defaultFile = File(_defaultCategoryRulesFile);
  if (!defaultFile.existsSync()) {
    final exampleFile = File(_exampleDefaultCategoryRulesFile);
    if (exampleFile.existsSync()) {
      defaultFile.writeAsStringSync(exampleFile.readAsStringSync());
    } else {
      // If example doesn't exist, return empty list
      return [];
    }
  }

  try {
    final content = defaultFile.readAsStringSync();
    return (jsonDecode(content) as List<dynamic>)
        .map((e) => CategoryRule.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}
