import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/transaction.dart';
import 'accounts_provider.dart';

class TransactionFilters {
  final String? account;
  final String? category;
  final String? startDate;
  final String? endDate;
  final String? search;
  final String sort;
  final int page;

  const TransactionFilters({
    this.account,
    this.category,
    this.startDate,
    this.endDate,
    this.search,
    this.sort = 'date_desc',
    this.page = 1,
  });

  TransactionFilters copyWith({
    String? account,
    String? category,
    String? startDate,
    String? endDate,
    String? search,
    String? sort,
    int? page,
    bool clearAccount = false,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return TransactionFilters(
      account: clearAccount ? null : (account ?? this.account),
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      search: clearSearch ? null : (search ?? this.search),
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }
}

final transactionFiltersProvider =
    StateProvider<TransactionFilters>((ref) => const TransactionFilters());

final transactionsProvider =
    FutureProvider<TransactionPage>((ref) async {
  final client = ref.read(apiClientProvider);
  final filters = ref.watch(transactionFiltersProvider);
  return client.getTransactions(
    account: filters.account,
    category: filters.category,
    startDate: filters.startDate,
    endDate: filters.endDate,
    search: filters.search,
    sort: filters.sort,
    page: filters.page,
  );
});
