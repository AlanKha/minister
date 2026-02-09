import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../theme.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        onPressed: syncState.isSyncing
            ? null
            : () async {
                await ref.read(syncProvider.notifier).syncAll();
                if (context.mounted) {
                  final state = ref.read(syncProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(state.error ?? state.lastResult ?? 'Done'),
                    ),
                  );
                }
              },
        icon: syncState.isSyncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : const Icon(Icons.sync_rounded, size: 20),
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        color: AppColors.textSecondary,
        tooltip: 'Sync transactions',
      ),
    );
  }
}
