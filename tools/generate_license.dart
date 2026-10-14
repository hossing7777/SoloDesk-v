// ignore_for_file: avoid_print
// Seller-only CLI: generates SoloDesk license keys.
//
//   cd tools && dart pub get
//   dart run generate_license.dart 5            # 5 new keys, appended to keys.json
//
// The "secret" in keys.json MUST equal the --dart-define=LICENSE_SECRET value
// used to build the app (see README). Keep keys.json private and backed up.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../lib/utils/license_algo.dart';

void main(List<String> args) {
  final count = args.isNotEmpty ? (int.tryParse(args.first) ?? 1) : 1;
  final file = File('keys.json');
  if (!file.existsSync()) {
    stderr.writeln('keys.json not found. Copy keys.json.example to keys.json and set a secret.');
    exit(1);
  }
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final secret = data['secret'] as String? ?? '';
  if (secret.isEmpty || secret.startsWith('REPLACE')) {
    stderr.writeln('Set a real "secret" in keys.json first.');
    exit(1);
  }
  final issued = (data['issued'] as List<dynamic>? ?? <dynamic>[]).cast<String>().toList();
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();

  for (var i = 0; i < count; i++) {
    final payload = List.generate(8, (_) => alphabet[rng.nextInt(alphabet.length)]).join();
    final key = LicenseAlgo.build(payload, secret);
    issued.add(key);
    print(key);
  }
  data['issued'] = issued;
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
}
