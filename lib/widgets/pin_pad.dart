import 'package:flutter/material.dart';
import 'package:solodesk/utils/ext.dart';

/// Numeric keypad that reports a completed PIN through [onComplete].
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onComplete, this.length = 4, this.extra});

  final ValueChanged<String> onComplete;
  final int length;

  /// Optional widget placed bottom-left (e.g. the fingerprint button).
  final Widget? extra;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  void _tap(String digit) {
    if (_pin.length >= widget.length) return;
    setState(() => _pin += digit);
    if (_pin.length == widget.length) {
      final done = _pin;
      setState(() => _pin = '');
      widget.onComplete(done);
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Widget _key(String digit) => Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 72,
          height: 72,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
            onPressed: () => _tap(digit),
            child: Text(digit, style: const TextStyle(fontSize: 24)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++)
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final r in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in r) _key(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 84, height: 84, child: widget.extra),
            _key('0'),
            SizedBox(
              width: 84,
              height: 84,
              child: IconButton(
                tooltip: context.l10n.delete,
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _back,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
