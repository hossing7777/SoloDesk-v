import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/home_shell.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/widgets/pin_pad.dart';

/// Unlock screen (default) or PIN setup flow (`setup: true`, pops `true`).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, this.setup = false});

  final bool setup;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _first;
  String _message = '';

  @override
  void initState() {
    super.initState();
    if (!widget.setup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  Future<void> _biometric() async {
    if (!ref.read(settingsProvider).biometric) return;
    final reason = context.l10n.biometricReason;
    final ok = await ref.read(authServiceProvider).authenticate(reason);
    if (ok && mounted) _done();
  }

  void _done() {
    if (widget.setup) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeShell()));
    }
  }

  Future<void> _onPin(String pin) async {
    final l = context.l10n;
    final auth = ref.read(authServiceProvider);
    if (widget.setup) {
      if (_first == null) {
        setState(() {
          _first = pin;
          _message = '';
        });
      } else if (_first == pin) {
        await auth.setPin(pin);
        if (mounted) _done();
      } else {
        setState(() {
          _first = null;
          _message = l.pinMismatch;
        });
      }
      return;
    }
    final ok = await auth.checkPin(pin);
    if (!mounted) return;
    if (ok) {
      _done();
    } else {
      setState(() => _message = l.wrongPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bio = !widget.setup && ref.watch(settingsProvider).biometric;
    final title = widget.setup ? (_first == null ? l.setPin : l.confirmPin) : l.enterPin;
    return Scaffold(
      appBar: widget.setup ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 24,
                  child: Text(_message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                PinPad(
                  onComplete: _onPin,
                  extra: bio
                      ? IconButton(
                          tooltip: l.useBiometric,
                          icon: const Icon(Icons.fingerprint, size: 32),
                          onPressed: _biometric,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
