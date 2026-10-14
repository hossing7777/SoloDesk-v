import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk/services/license_service.dart';
import 'package:solodesk/utils/license_algo.dart';

void main() {
  const secret = 'test-secret';

  test('generated key validates with the same secret', () {
    final key = LicenseAlgo.build('ABCD1234', secret);
    expect(key, matches(RegExp(r'^SOLO-[A-Z0-9]{8}-[0-9A-F]{8}$')));
    expect(LicenseAlgo.validate(key, secret), isTrue);
  });

  test('validation ignores case and surrounding spaces', () {
    final key = LicenseAlgo.build('ZXCV0987', secret);
    expect(LicenseAlgo.validate('  ${key.toLowerCase()}  ', secret), isTrue);
  });

  test('wrong secret, tampered payload and bad format are rejected', () {
    final key = LicenseAlgo.build('ABCD1234', secret);
    expect(LicenseAlgo.validate(key, 'other-secret'), isFalse);
    expect(LicenseAlgo.validate(key.replaceFirst('ABCD1234', 'ABCD1235'), secret), isFalse);
    expect(LicenseAlgo.validate('', secret), isFalse);
    expect(LicenseAlgo.validate('SOLO-SHORT-00000000', secret), isFalse);
  });

  test('LicenseService uses the default secret when none is defined', () {
    final key = LicenseAlgo.build('QWER5678', kDefaultLicenseSecret);
    expect(LicenseService.validate(key), isTrue);
    expect(LicenseService.validate('SOLO-AAAAAAAA-00000000'), isFalse);
  });
}
