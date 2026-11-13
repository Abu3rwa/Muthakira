/// A slim, app-wide notice when the device has no network.
library;

import 'package:flutter/material.dart';

import '../../app/app_context.dart';
import '../../core/theme/tokens.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.services.connectivity,
      builder: (BuildContext context, Widget? _) {
        if (!context.services.connectivity.isOffline) return const SizedBox.shrink();
        final ColorScheme scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.surfaceContainerHighest,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.gutterOf(context),
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      context.l10n.offlineBanner,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
