import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/about_screen.dart';
import 'package:solodesk/screens/lock_screen.dart';
import 'package:solodesk/screens/pricing_screen.dart';
import 'package:solodesk/services/backup_service.dart';
import 'package:solodesk/services/locale_service.dart';
import 'package:solodesk/theme/colors.dart';
import 'package:solodesk/utils/constants.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/widgets/dialogs.dart';
import 'package:solodesk/utils/limits.dart';
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _bizName =
      TextEditingController(text: ref.read(settingsProvider).businessName);
  late final TextEditingController _bizEmail =
      TextEditingController(text: ref.read(settingsProvider).businessEmail);
  bool _bioAvailable = false;

  @override
  void initState() {
    super.initState();
    ref.read(authServiceProvider).biometricAvailable().then((v) {
      if (mounted) setState(() => _bioAvailable = v);
    });
  }

  @override
  void dispose() {
    _bizName.dispose();
    _bizEmail.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final ext = x.path.contains('.') ? x.path.split('.').last : 'png';
    final dest = '${dir.path}/logo_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(x.path).copy(dest);
    await ref.read(settingsProvider.notifier).setLogoPath(dest);
  }

  Future<void> _toggleLock(bool on) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (on) {
      final ok = await pushPage<bool>(context, const LockScreen(setup: true));
      if (ok == true) await notifier.setLockEnabled(true);
    } else {
      await ref.read(authServiceProvider).clearPin();
      await notifier.setLockEnabled(false);
    }
  }

  /// "Reset all data" needs TWO confirmations.
  Future<void> _reset() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDialog(context, l.resetConfirm1, l.resetData)) return;
    if (!mounted) return;
    if (!await confirmDialog(context, l.resetConfirm2, l.resetData)) return;
    await ref.read(dbProvider).resetAll();
    ref.invalidate(clientsProvider);
    ref.invalidate(projectsProvider);
    ref.invalidate(invoicesProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(timeEntriesProvider);
    messenger.showSnackBar(SnackBar(content: Text(l.resetDone)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final demo = ref.watch(isDemoProvider);
    final theme = Theme.of(context);
    Widget header(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(t, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          header(l.appearance),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => notifier.setThemeMode(v.first),
          ),
          const SizedBox(height: 16),
          Text(l.accentColor),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (var i = 0; i < AppColors.accents.length; i++)
                Semantics(
                  button: true,
                  selected: s.accent == i,
                  label: '${l.accentColor} ${i + 1}',
                  child: InkResponse(
                    onTap: () => notifier.setAccent(i),
                    radius: 28,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accents[i],
                      child: s.accent == i ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: s.locale,
            decoration: InputDecoration(labelText: l.language),
            items: [
              DropdownMenuItem(value: '', child: Text(l.systemDefault)),
              for (final c in LocaleService.codes)
                DropdownMenuItem(value: c, child: Text(LocaleService.nativeName(c))),
            ],
            onChanged: (v) => notifier.setLocale(v ?? ''),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: kCurrencies.contains(s.currency) ? s.currency : 'USD',
            decoration: InputDecoration(labelText: l.currency),
            items: [for (final c in kCurrencies) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => notifier.setCurrency(v ?? 'USD'),
          ),
          if (!demo) ...[
            header(l.businessProfile),
            TextField(
              controller: _bizName,
              decoration: InputDecoration(labelText: l.businessName),
              onChanged: notifier.setBusinessName,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bizEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l.email),
              onChanged: notifier.setBusinessEmail,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (s.logoPath.isNotEmpty && File(s.logoPath).existsSync())
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Image.file(File(s.logoPath), height: 56, excludeFromSemantics: true),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l.chooseLogo),
                  onPressed: _pickLogo,
                ),
              ],
            ),
            header(l.security),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.appLock),
              value: s.lockEnabled,
              onChanged: _toggleLock,
            ),
            if (s.lockEnabled && _bioAvailable)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.useBiometric),
                value: s.biometric,
                onChanged: notifier.setBiometric,
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup_outlined),
              title: Text(l.backup),
              onTap: () async {
                if (!await ensurePro(context, ref)) return;
                await BackupService.shareBackup(ref.read(dbProvider));
              },
            ),
          ],
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text(l.resetData, style: TextStyle(color: theme.colorScheme.error)),
            onTap: _reset,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(l.pricing),
            onTap: () => pushPage<void>(context, const PricingScreen()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l.about),
            onTap: () => pushPage<void>(context, const AboutScreen()),
          ),
        ],
      ),
    );
  }
}
