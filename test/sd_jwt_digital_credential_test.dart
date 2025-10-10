import 'package:test/test.dart';
import 'package:dcql/src/credential_format/credential_format.dart';

void main() {
  group('SdJwtDigitalCredential', () {
    test('should have format dcSdJwt', () {
      expect(CredentialFormat.dcSdJwt, isNotNull);
      expect(CredentialFormat.dcSdJwt.toString(), contains('dcSdJwt'));
    });

    test('should have format constant exists', () {
      final format = CredentialFormat.dcSdJwt;
      expect(format, isNotNull);
    });
  });
}
