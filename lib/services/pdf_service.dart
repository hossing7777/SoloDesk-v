import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:solodesk/l10n/gen/app_localizations.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/settings_provider.dart';
import 'package:solodesk/services/locale_service.dart';
import 'package:solodesk/utils/format.dart';

/// Localized labels used inside the PDF.
class PdfLabels {
  const PdfLabels(this.l);

  factory PdfLabels.from(AppLocalizations l) => PdfLabels(l);

  final AppLocalizations l;
}

class PdfService {
  PdfService._();

  static Future<pw.MemoryImage?> _logo(Settings s, bool show) async {
    if (!show || s.logoPath.isEmpty) return null;
    final file = File(s.logoPath);
    if (!file.existsSync()) return null;
    return pw.MemoryImage(await file.readAsBytes());
  }

  /// Builds the invoice PDF. Uses the STATIC Vazirmatn fonts so Persian and
  /// Arabic letters connect correctly, and wraps content in an RTL
  /// [pw.Directionality] for fa/ar.
  static Future<Uint8List> build({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Client? client,
    required Settings settings,
    required String lang,
    required PdfLabels labels,
    required Map<String, Object?> template,
  }) async {
    final l = labels.l;
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Vazirmatn/Vazirmatn-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Vazirmatn/Vazirmatn-Bold.ttf'));

    final isRtl = LocaleService.isRtl(lang);
    final dir = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final color = PdfColor.fromHex((template['primaryColor'] as String?) ?? '#4F46E5');
    final filled = (template['headerFilled'] as bool?) ?? true;
    final logo = await _logo(settings, (template['showLogo'] as bool?) ?? true);
    final cur = settings.currency;

    final subtotal = items.fold<double>(0, (a, i) => a + i.amount);
    final taxAmount = subtotal * invoice.tax / 100;

    pw.Widget wrap(pw.Widget child) => pw.Directionality(textDirection: dir, child: child);
    pw.TextStyle style({bool strong = false, PdfColor? c, double? size}) => pw.TextStyle(
          fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: c,
          fontSize: size,
        );
    pw.Widget cell(String t, {bool strong = false, PdfColor? c}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: pw.Text(t, style: style(strong: strong, c: c)),
        );
    pw.Widget totalRow(String label, String value, {bool strong = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: style(strong: strong)),
              pw.Text(value, style: style(strong: strong)),
            ],
          ),
        );

    final headColor = filled ? PdfColors.white : PdfColors.black;
    final table = pw.Table(
      border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300)),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: filled ? color : PdfColors.grey200),
          children: [
            cell(l.description, strong: true, c: headColor),
            cell(l.quantity, strong: true, c: headColor),
            cell(l.price, strong: true, c: headColor),
            cell(l.total, strong: true, c: headColor),
          ],
        ),
        for (final i in items)
          pw.TableRow(children: [
            cell(i.description),
            cell(Fmt.number(i.qty)),
            cell(i.price.toStringAsFixed(2)),
            cell(i.amount.toStringAsFixed(2)),
          ]),
      ],
    );

    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          wrap(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logo != null) pw.Image(logo, height: 48),
                    if (settings.businessName.isNotEmpty)
                      pw.Text(settings.businessName, style: style(strong: true, size: 16)),
                    if (settings.businessEmail.isNotEmpty) pw.Text(settings.businessEmail),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${l.invoiceNumber}: ${invoice.number}',
                      style: style(strong: true, c: color, size: 18),
                    ),
                    pw.Text('${l.issueDate}: ${Fmt.date(invoice.issueDate)}'),
                    pw.Text('${l.dueDate}: ${Fmt.date(invoice.dueDate)}'),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          wrap(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(l.billTo, style: style(strong: true, c: color)),
                pw.Text(client?.name ?? '-'),
                if (client != null && client.email.isNotEmpty) pw.Text(client.email),
                if (client != null && client.address.isNotEmpty) pw.Text(client.address),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          wrap(table),
          pw.SizedBox(height: 12),
          wrap(
            pw.Align(
              alignment: isRtl ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
              child: pw.SizedBox(
                width: 210,
                child: pw.Column(
                  children: [
                    totalRow(l.subtotal, Fmt.money(subtotal, cur)),
                    if (invoice.tax > 0)
                      totalRow('${l.tax} ${Fmt.number(invoice.tax)}', Fmt.money(taxAmount, cur)),
                    totalRow(l.total, Fmt.money(subtotal + taxAmount, cur), strong: true),
                  ],
                ),
              ),
            ),
          ),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            wrap(pw.Text('${l.notes}: ${invoice.notes}')),
          ],
        ],
      ),
    );
    return doc.save();
  }
}
