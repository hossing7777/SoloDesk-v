import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(value, style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
