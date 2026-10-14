import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:solodesk/l10n/gen/app_localizations.dart';

/// Loads the JSON invoice templates from assets/invoice_templates/.
class TemplateService {
  TemplateService._();

  static const List<String> ids = ['classic', 'modern', 'minimal'];

  static Future<Map<String, Object?>> load(String id) async {
    final safe = ids.contains(id) ? id : 'classic';
    final raw = await rootBundle.loadString('assets/invoice_templates/$safe.json');
    return (jsonDecode(raw) as Map<String, dynamic>).cast<String, Object?>();
  }
}

String templateLabel(AppLocalizations l, String id) => switch (id) {
      'modern' => l.templateModern,
      'minimal' => l.templateMinimal,
      _ => l.templateClassic,
    };
