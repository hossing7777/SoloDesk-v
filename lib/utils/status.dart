import 'package:flutter/material.dart';
import 'package:solodesk/l10n/gen/app_localizations.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/theme/colors.dart';

String statusLabel(AppLocalizations l, Invoice i) {
  if (i.status == Invoice.paid) return l.statusPaid;
  if (i.isOverdue) return l.statusOverdue;
  if (i.status == Invoice.sent) return l.statusSent;
  return l.statusDraft;
}

Color statusColor(Invoice i) {
  if (i.status == Invoice.paid) return AppColors.success;
  if (i.isOverdue) return AppColors.danger;
  if (i.status == Invoice.sent) return AppColors.warning;
  return AppColors.neutral;
}
