import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../utils/snackbar_helpers.dart';
import '../theme.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: IconButton(
        onPressed: syncState.isSyncing
            ? null
            : () async {
                await ref.read(syncProvider.notifier).syncAll();
                if (context.mounted) {
                  final state = ref.read(syncProvider);
                  if (state.error != null) {
                    showErrorSnackbar(context, state.error!);
                  } else {
                    showSuccessSnackbar(
                      context,
                      state.lastResult ?? 'Sync complete',
                    );
                  }
                }
              },
        icon: syncState.isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : const Icon(Icons.sync_rounded, size: 18),
        iconSize: 18,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        color: AppColors.textSecondary,
        tooltip: 'Sync transactions',
      ),
    );
  }
}
