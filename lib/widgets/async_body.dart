import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders loading / error / data states of an [AsyncValue].
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => value.when(
        data: builder,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      );
}
