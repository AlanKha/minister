import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/account.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final accountsProvider =
    FutureProvider<List<LinkedAccount>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getAccounts();
});
