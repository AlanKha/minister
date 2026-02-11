import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accounts_provider.dart';

final balancesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getBalances();
});
