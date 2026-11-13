/// Identity block for the profile screen: name, contacts, class and stream.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class ProfileAccountCard extends StatelessWidget {
  const ProfileAccountCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.classLabel,
    required this.streamLabel,
  });

  final String name;
  final String? email;
  final String? phone;
  final String? classLabel;
  final String? streamLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String trimmed = name.trim();
    final String initial = trimmed.isEmpty ? '?' : String.fromCharCode(trimmed.runes.first);
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              child: Text(initial, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                  if ((email ?? '').isNotEmpty)
                    Text(
                      email!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  if ((phone ?? '').isNotEmpty)
                    Text(
                      phone!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  if (classLabel != null || streamLabel != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: <Widget>[
                        if (classLabel != null) _Pill(label: classLabel!),
                        if (streamLabel != null) _Pill(label: streamLabel!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
