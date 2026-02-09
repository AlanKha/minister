import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return IconButton(
      onPressed: syncState.isSyncing
          ? null
          : () async {
              await ref.read(syncProvider.notifier).syncAll();
              if (context.mounted) {
                final state = ref.read(syncProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error ?? state.lastResult ?? 'Done'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
      icon: syncState.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      tooltip: 'Sync transactions',
    );
  }
}
