import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/utils/ext.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<List<String>> _info() async {
    final pkg = await PackageInfo.fromPlatform();
    String device = '';
    try {
      final a = await DeviceInfoPlugin().androidInfo;
      device = '${a.manufacturer} ${a.model} · Android ${a.version.release}';
    } catch (_) {
      device = '';
    }
    return ['${pkg.version} (${pkg.buildNumber})', device];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isPro = ref.watch(isProProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: FutureBuilder<List<String>>(
        future: _info(),
        builder: (context, snap) {
          final data = snap.data ?? const ['…', ''];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: Image.asset('assets/logo.png', width: 88, height: 88)),
              const SizedBox(height: 12),
              Center(child: Text(l.appName, style: Theme.of(context).textTheme.headlineMedium)),
              const SizedBox(height: 24),
              Card(child: ListTile(title: Text(l.version), subtitle: Text(data[0]))),
              Card(
                child: ListTile(
                  title: Text(l.licenseStatus),
                  subtitle: Text(isPro ? l.licensePro : l.licenseFree),
                ),
              ),
              if (data[1].isNotEmpty) Card(child: ListTile(title: Text(data[1]))),
            ],
          );
        },
      ),
    );
  }
}
