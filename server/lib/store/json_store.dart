import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:minister_shared/models/account.dart';
import 'package:minister_shared/models/transaction.dart';

late final String dataDir;

void initStore(String serverRoot) {
  dataDir = p.join(serverRoot, 'data');
  Directory(dataDir).createSync(recursive: true);
}

String get _accountFile => p.join(dataDir, 'linked_account.json');
String get _txFile => p.join(dataDir, 'transactions.json');
String get _cleanFile => p.join(dataDir, 'transactions_clean.json');
String get _overridesFile => p.join(dataDir, 'category_overrides.json');

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
  File(_accountFile)
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data.toJson()));
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

String accountLabel(LinkedAccount acct) {
  return [acct.institution, acct.displayName, acct.last4 != null ? '****${acct.last4}' : null]
      .where((s) => s != null && s.isNotEmpty)
      .join(' ');
}
