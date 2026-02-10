import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/account.dart';
import '../api/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final accountsProvider =
    FutureProvider<List<LinkedAccount>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getAccounts();
});
