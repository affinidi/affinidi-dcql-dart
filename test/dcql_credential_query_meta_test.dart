import 'package:dcql/src/dcql_credential/dcql_credential.dart';
import 'package:dcql/src/dcql_credential_query/dcql_credential_query.dart';
import 'package:dcql/src/dcql_meta/dcql_meta.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('DcqlCredentialQuery meta matching', () {
    group('W3C meta matching', () {
      test('should match when VC has one of the requested types', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(
                typeValues: [
                  ['EmailCredential']
                ],
              ),
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred']?.isNotEmpty, isTrue);
        expect(result.fulfilled, isTrue);
      });

      test('should not match when types do not overlap', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(
                typeValues: [
                  ['OtherType']
                ],
              ),
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred'], isNull);
        expect(result.fulfilled, isFalse);
      });

      test('should match with multiple type options', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'PersonCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(
                typeValues: [
                  ['EmailCredential'],
                  ['PersonCredential'],
                ],
              ),
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred']?.isNotEmpty, isTrue);
        expect(result.fulfilled, isTrue);
      });

      test('should match when no meta constraints provided', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.ldpVc,
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred']?.isNotEmpty, isTrue);
        expect(result.fulfilled, isTrue);
      });
    });

    group('format mismatch', () {
      test('should not match when credential format differs', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.dcSdJwt,
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred'], isNull);
        expect(result.fulfilled, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle null meta gracefully', () {
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {'id': 'did:example:holder'},
          id: 'urn:uuid:test',
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred',
              format: CredentialFormat.ldpVc,
              meta: null, // No meta constraints
            ),
          ],
        );

        final result = query.query([vc]);
        expect(result.verifiableCredentials['cred']?.isNotEmpty, isTrue);
        expect(result.fulfilled, isTrue);
      });
    });
  });
}
