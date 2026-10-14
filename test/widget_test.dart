import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk/l10n/gen/app_localizations.dart';
import 'package:solodesk/services/locale_service.dart';
import 'package:solodesk/theme/app_theme.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/widgets/empty_state.dart';
import 'package:solodesk/widgets/pin_pad.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: AppTheme.build(const Color(0xFF4F46E5), Brightness.light),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('EmptyState shows title and message', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(
      icon: Icons.people_outline,
      title: 'Nothing here',
      message: 'Add something',
    )));
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add something'), findsOneWidget);
  });

  testWidgets('all 10 locales load and fa/ar are RTL', (tester) async {
    expect(AppLocalizations.supportedLocales.length, 10);
    for (final code in LocaleService.codes) {
      await tester.pumpWidget(_wrap(
        Builder(builder: (c) => Text(AppLocalizations.of(c).navClients)),
        locale: Locale(code),
      ));
      await tester.pumpAndSettle();
      final dir = Directionality.of(tester.element(find.byType(Text)));
      expect(dir, LocaleService.isRtl(code) ? TextDirection.rtl : TextDirection.ltr,
          reason: code);
    }
  });

  testWidgets('PinPad reports the completed PIN', (tester) async {
    String? result;
    await tester.pumpWidget(_wrap(PinPad(onComplete: (p) => result = p)));
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    expect(result, '1234');
  });

  test('Fmt helpers', () {
    expect(Fmt.money(12.5, 'USD'), '12.50 USD');
    expect(Fmt.parse('1,5'), 1.5);
    expect(Fmt.duration(const Duration(hours: 1, minutes: 2, seconds: 3)), '01:02:03');
    expect(AppTheme.build(Colors.indigo, Brightness.dark).brightness, Brightness.dark);
  });
}
