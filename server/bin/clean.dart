import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:finance_server/config.dart';
import 'package:finance_server/store/json_store.dart';
import 'package:finance_server/services/cleaning_service.dart';

void main() {
  loadConfig();

  final serverRoot = p.dirname(p.dirname(Platform.script.toFilePath()));
  initStore(serverRoot);

  print('Server root: $serverRoot');
  print('Data directory: ${p.join(serverRoot, 'data')}');
  print('\nCleaning transactions...');
  final cleaned = cleanAllTransactions();
  print('✓ Cleaned ${cleaned.length} transactions');

  // Show some examples with multiple spaces
  print('\nExamples with cleaned descriptions:');
  for (var tx in cleaned.take(10)) {
    if (tx.description.contains('  ')) {
      print('FOUND MULTIPLE SPACES: "${tx.description}"');
    } else {
      print('OK: "${tx.description}"');
    }
  }

  // Verify the file was written
  final cleanFile = p.join(serverRoot, 'data', 'transactions_clean.json');
  print('\nWritten to: $cleanFile');
  final fileContent = File(cleanFile).readAsStringSync();
  final lines = fileContent.split('\n');
  print('First description line from file:');
  for (var line in lines) {
    if (line.contains('"description"')) {
      print('  $line');
      break;
    }
  }
}
