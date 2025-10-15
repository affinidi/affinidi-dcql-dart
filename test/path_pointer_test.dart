import 'package:dcql/dcql.dart';
import 'package:test/test.dart';

void main() {
  group('W3C Digital Credential path pointer', () {
    late W3CDigitalCredential credential;

    setUp(() {
      // Example from the spec with additional fields
      credential = W3CDigitalCredential.fromLdVcDataModelV1({
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'credentialSubject': {
          'id': 'did:example:ebfeb1f712ebc6f1c276e12ec21',
          'degrees': [
            {
              'type': 'BachelorDegree',
              'name': 'Bachelor of Science and Arts',
              'year': 2020,
            },
            {'type': 'MasterDegree', 'name': 'Master of Science', 'year': 2023},
          ],
          'citizenship': [
            {'country': 'US', 'documentNumber': 'N123'},
            {'country': 'Canada', 'documentNumber': 'C456'},
          ],
          'address': {
            'street_address': '123 Main St',
            'locality': 'Anytown',
            'region': 'Anystate',
            'country': 'US',
          },
        },
        'holder': {
          'id': 'did:key:zQ3shnHRFYxDpASTxaTFBMcqtFASxyzctDx8xYj2USw7QUaLb',
        },
        'id': 'claimId:ee3882a6b3058195',
        'issuanceDate': '2025-01-23T21:01:23.162Z',
        'issuer': 'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6',
        'proof': {
          'type': 'EcdsaSecp256k1Signature2019',
          'created': '2025-01-23T21:01:31Z',
          'verificationMethod':
              'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6#zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6',
          'proofPurpose': 'assertionMethod',
          'jws':
              'eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..ZwNL-5Gva80Xc0FR6v1R6wCVPPMAYzriWu6_szFD48YGPNQJPV66XsDHNjTGyQOyuRy7a3srX3diI5_1527Ttg',
        },
        'type': ['VerifiableCredential', 'UniversityDegree'],
      });
    });

    group('credential query with path pointers', () {
      test('should match credential with array wildcard path', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'citizenship',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'country',
                  path: ['credentialSubject', 'citizenship', null, 'country'],
                  values: ['US'],
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(result.fulfilled, isTrue);
      });

      test('should match credential with specific array index', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'degree',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'masterDegree',
                  path: ['credentialSubject', 'degrees', 1, 'type'],
                  values: ['MasterDegree'],
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(result.fulfilled, isTrue);
      });
    });

    group('path access operations', () {
      test('should access simple property', () {
        final result = credential.getValueByPath(['credentialSubject', 'id']);
        expect(result, equals('did:example:ebfeb1f712ebc6f1c276e12ec21'));
      });

      test('should access nested object property', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'address',
          'country',
        ]);
        expect(result, equals('US'));
      });

      test('should access array with specific index', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'degrees',
          0,
          'type',
        ]);
        expect(result, equals('BachelorDegree'));
      });

      test('should match array with wildcard', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'degrees',
          null,
          'type',
        ]);
        expect(
          result,
          equals(['BachelorDegree', 'MasterDegree']),
        ); // Should return all degrees
      });

      test('should match array wildcard with multiple possible matches', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'citizenship',
          null,
          'country',
        ]);
        expect(result, equals(['US', 'Canada'])); // Should return all countries
      });

      test('should return null for non-existent path', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'nonexistent',
          'field',
        ]);
        expect(result, isNull);
      });

      test('should return null for index out of bounds', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'degrees',
          99,
          'type',
        ]);
        expect(result, isNull);
      });
    });

    group('query validation', () {
      test('should not match when array index is wrong', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'degree',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'masterDegree',
                  path: ['credentialSubject', 'degrees', 0, 'type'],
                  values: ['MasterDegree'], // MasterDegree is at index 1, not 0
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when value is at different index',
        );
      });

      test('should not match when value exists but is different', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'degree',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'bachelordegree',
                  path: ['credentialSubject', 'degrees', 0, 'type'],
                  values: ['PhD'], // Actual value is BachelorDegree
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when value exists but is different',
        );
      });

      test('should not match with nested path beyond array', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'citizenship',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'country',
                  path: [
                    'credentialSubject',
                    'citizenship',
                    'country',
                  ], // Missing array index or wildcard
                  values: ['US'],
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when array accessor is missing',
        );
      });

      test('should not match with wrong credential format', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'degree',
              format:
                  CredentialFormat.dcSdJwt, // Wrong format for W3C credential
              claims: [
                DcqlClaim(
                  id: 'bachelordegree',
                  path: ['credentialSubject', 'degrees', 0, 'type'],
                  values: ['BachelorDegree'],
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when credential format is wrong',
        );
      });

      test('should not match with wildcards in non-array paths', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'address',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'countryWildcard',
                  path: [
                    'credentialSubject',
                    'address',
                    null,
                    'country',
                  ], // address is not an array
                  values: ['US'],
                ),
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when wildcard is used in object path',
        );
      });

      test('should not match with multiple claim sets when one is invalid', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'composite',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                  id: 'validClaim',
                  path: ['credentialSubject', 'degrees', 0, 'type'],
                  values: ['BachelorDegree'],
                ),
                DcqlClaim(
                  id: 'invalidClaim',
                  path: ['credentialSubject', 'nonexistent', null, 'field'],
                  values: ['someValue'],
                ),
              ],
              claimSets: [
                ['validClaim', 'invalidClaim'],
              ],
            ),
          ],
        );

        final result = query.query([credential]);
        expect(
          result.fulfilled,
          isFalse,
          reason: 'Should not match when any claim in a claim set is invalid',
        );
      });
    });
  });
}
