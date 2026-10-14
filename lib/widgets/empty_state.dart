import 'package:flutter/material.dart';

/// Friendly placeholder shown when a list has no items.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message});

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, size: 44, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
