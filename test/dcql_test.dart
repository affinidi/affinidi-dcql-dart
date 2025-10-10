import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:dcql/src/dcql_credential/dcql_credential.dart';
import 'package:dcql/src/dcql_credential_query/dcql_credential_query.dart';
import 'package:dcql/src/dcql_credential_set/dcql_credential_set.dart';
import 'package:dcql/src/dcql_meta/dcql_meta.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:dcql/src/digital_credential/digital_credential.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('DcqlClaim validation', () {
    test('should validate valid claim', () {
      final claim = DcqlClaim(id: 'name', path: ['name'], values: ['Alice']);
      final result = claim.validate();
      expect(result.isValid, isTrue);
    });

    test('should fail when id is missing when claimSets present', () {
      final claim = DcqlClaim(id: null, path: ['name']);
      final result = claim.validate(
        claimSets: [
          ['name'],
        ],
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains('id is required when claim_sets is present'),
      );
    });

    test('should fail when path is empty', () {
      final claim = DcqlClaim(id: 'foo', path: []);
      final result = claim.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, contains('path must be a non-empty array'));
    });

    test('should fail when id characters are invalid', () {
      final claim = DcqlClaim(id: 'bad id!', path: ['foo']);
      final result = claim.validate();
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('alphanumeric')), isTrue);
    });

    test('should fail when values are not string/int/bool', () {
      final claim = DcqlClaim(
        id: 'foo',
        path: ['foo'],
        values: [1, 'a', false, 3.14],
      );
      final result = claim.validate();
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('strings, integers or boolean')),
        isTrue,
      );
    });
    test('should validate empty id string', () {
      final claim = DcqlClaim(id: '', path: ['name']);
      final result = claim.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, contains('id must be a non-empty string'));
    });

    test('should validate duplicate id in claims array', () {
      final claim1 = DcqlClaim(id: 'name', path: ['name']);
      final claim2 = DcqlClaim(id: 'name', path: ['surname']);
      final claim3 = DcqlClaim(id: 'other', path: ['other']);
      final result = claim1.validate(claims: [claim1, claim2, claim3]);
      expect(result.isValid, isFalse);
      expect(
          result.errors.any((e) => e.contains(
              'id must not be present more than once in claims array')),
          isTrue);
    });
    test('should validate path elements not empty', () {
      final claim = DcqlClaim(id: 'test', path: ['name', '']);
      final result = claim.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, contains('path elements must not be empty'));
    });
  });

  group('DcqlCredential validation', () {
    test('should pass validation when valid credential', () {
      final cred = DcqlCredential(
        id: 'cred1',
        format: CredentialFormat.dcSdJwt,
        claims: [
          DcqlClaim(id: 'name', path: ['name']),
        ],
      );
      final result = cred.validate();
      expect(result.isValid, isTrue);
    });

    test('should fail when id is empty', () {
      final cred = DcqlCredential(id: '', format: CredentialFormat.dcSdJwt);
      final result = cred.validate();
      expect(result.isValid, isFalse);
    });

    test('should fail when meta is invalid for dcSdJwt', () {
      final cred = DcqlCredential(
        id: 'cred1',
        format: CredentialFormat.dcSdJwt,
        meta: DcqlMeta(),
      );
      final result = cred.validate();
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('vct_values')), isTrue);
    });
  });

  group('DcqlCredentialSet', () {
    test('should fail when options are empty', () {
      final set = DcqlCredentialSet(
        options: [
          ['cred1', 'cred2'],
          ['cred3'],
        ],
      );
      expect(set.options.isNotEmpty, isTrue);
      expect(set.options.first, contains('cred1'));
    });
    test('should default to true when required is not set', () {
      final set = DcqlCredentialSet(
        options: [
          ['cred1'],
        ],
      );
      expect(set.required, isTrue);
    });
  });

  group('DcqlMeta validation', () {
    test('should fail when dcSdJwt requires vct_values', () {
      final meta = DcqlMeta();
      final result = meta.validate(format: CredentialFormat.dcSdJwt);
      expect(result.isValid, isFalse);
    });
    test('should pass validation when valid meta for dcSdJwt', () {
      final meta = DcqlMeta.forDcSdJwt(vctValues: ['vct1']);
      final result = meta.validate(format: CredentialFormat.dcSdJwt);
      expect(result.isValid, isTrue);
    });
  });

  group('DcqlCredentialQuery matching (ldpVc)', () {
    final aliceDigitalVc = VcTestData.createW3CCredential(
      types: ['VerifiableCredential', 'PersonCredential'],
      credentialSubject: {'name': 'Alice', 'age': 30},
      id: 'urn:uuid:alice',
    );

    final bobDigitalVc = VcTestData.createW3CCredential(
      types: ['VerifiableCredential', 'PersonCredential'],
      credentialSubject: {'name': 'Bob', 'age': 25},
      id: 'urn:uuid:bob',
    );

    final query = DcqlCredentialQuery(
      credentials: [
        DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(
              id: 'name',
              path: ['credentialSubject', 'name'],
              values: ['Alice'],
            ),
            DcqlClaim(
              id: 'age',
              path: ['credentialSubject', 'age'],
              values: [30],
            ),
          ],
          meta: DcqlMeta.forW3C(
            typeValues: [
              ['PersonCredential']
            ],
          ),
        ),
      ],
    );

    test('should match correct VC and fulfilled is true', () {
      final result = query.query([aliceDigitalVc, bobDigitalVc]);
      expect(result.verifiableCredentials['cred1']!.length, 1);
      expect(result.fulfilled, isTrue);
    });

    test('should return empty if no claim value match', () {
      final query2 = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred2',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(
                id: 'name',
                path: ['credentialSubject', 'name'],
                values: ['Charlie'],
              ),
            ],
            meta: DcqlMeta.forW3C(
              typeValues: [
                ['PersonCredential']
              ],
            ),
          ),
        ],
      );
      final result = query2.query([aliceDigitalVc, bobDigitalVc]);
      expect(result.verifiableCredentials.isEmpty, isTrue);
      expect(result.fulfilled, isFalse);
    });
  });

  group('W3C VC parsing (basic)', () {
    test('should extract credentialSubject value by path', () {
      final vc = W3CDigitalCredential.fromLdVcDataModelV1({
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'type': ['VerifiableCredential', 'Email'],
        'issuer': 'did:example:issuer',
        'issuanceDate': '2025-01-01T00:00:00Z',
        'credentialSubject': {'email': 'alice@example.com'},
        'id': 'urn:uuid:test-email',
        'proof': {
          'type': 'EcdsaSecp256k1Signature2019',
          'created': '2025-01-01T00:00:00Z',
          'verificationMethod': 'did:example:issuer#key-1',
          'proofPurpose': 'assertionMethod',
          'jws': 'eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ..sig'
        }
      });
      final value = vc.getValueByPath(['credentialSubject', 'email']);
      expect(value, 'alice@example.com');
    });
  });
  group('W3C meta type_values matching', () {
    Map<String, dynamic> w3cVc({required List<String> types}) => {
          '@context': ['https://www.w3.org/2018/credentials/v1'],
          'type': types,
          'issuer': 'did:example:issuer',
          'issuanceDate': '2025-01-01T00:00:00Z',
          'credentialSubject': {'id': 'did:example:holder'},
          'id': 'urn:uuid:meta-test',
          'proof': {
            'type': 'EcdsaSecp256k1Signature2019',
            'created': '2025-01-01T00:00:00Z',
            'verificationMethod': 'did:example:issuer#key-1',
            'proofPurpose': 'assertionMethod',
            'jws': 'eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ..sig'
          }
        };

    test('should match when VC has one of the requested types', () {
      final vc = W3CDigitalCredential.fromLdVcDataModelV1(
        w3cVc(types: ['VerifiableCredential', 'Email']),
      );
      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred',
            format: CredentialFormat.ldpVc,
            meta: DcqlMeta.forW3C(
              typeValues: [
                ['Email']
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
      final vc = W3CDigitalCredential.fromLdVcDataModelV1(
        w3cVc(types: ['VerifiableCredential', 'Email']),
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
      expect(result.verifiableCredentials['cred'] == null, isTrue);
      expect(result.fulfilled, isFalse);
    });
  });

  group('DcqlClaim serialization', () {
    test('should serialize to JSON', () {
      final claim = DcqlClaim(
        id: 'email-claim',
        path: ['credentialSubject', 'email'],
        values: ['alice@example.com'],
      );

      final json = claim.toJson();
      expect(json['id'], 'email-claim');
      expect(json['path'], ['credentialSubject', 'email']);
      expect(json['values'], ['alice@example.com']);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 'email-claim',
        'path': ['credentialSubject', 'email'],
        'values': ['alice@example.com'],
      };

      final claim = DcqlClaim.fromJson(json);
      expect(claim.id, 'email-claim');
      expect(claim.path, ['credentialSubject', 'email']);
      expect(claim.values, ['alice@example.com']);
    });

    test('should handle round-trip serialization', () {
      final original = DcqlClaim(
        id: 'email-claim',
        path: ['credentialSubject', 'email'],
        values: ['alice@example.com'],
      );

      final json = original.toJson();
      final deserialized = DcqlClaim.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.path, original.path);
      expect(deserialized.values, original.values);
    });
  });

  group('Claims without ID matching', () {
    test('should match claims without ID when no claim_sets are present', () {
      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {'name': 'Alice', 'age': 30},
      );

      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred1',
            format: CredentialFormat.ldpVc,
            claims: [
              // Claim without ID - should still be matched
              DcqlClaim(
                path: ['credentialSubject', 'name'],
                values: ['Alice'],
              ),
              // Claim with ID
              DcqlClaim(
                id: 'age',
                path: ['credentialSubject', 'age'],
                values: [30],
              ),
            ],
          ),
        ],
      );

      final result = query.query([vc]);
      expect(result.verifiableCredentials['cred1']?.isNotEmpty, isTrue);
      expect(result.fulfilled, isTrue);
    });

    test('should reject when claim without ID does not match', () {
      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {'name': 'Bob', 'age': 30}, // name doesn't match
      );

      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred1',
            format: CredentialFormat.ldpVc,
            claims: [
              // Claim without ID that won't match
              DcqlClaim(
                path: ['credentialSubject', 'name'],
                values: ['Alice'], // Expected Alice, but got Bob
              ),
              // Claim with ID that matches
              DcqlClaim(
                id: 'age',
                path: ['credentialSubject', 'age'],
                values: [30],
              ),
            ],
          ),
        ],
      );

      final result = query.query([vc]);
      expect(result.verifiableCredentials.containsKey('cred1'), isFalse);
      expect(result.fulfilled, isFalse);
    });

    test('should match claims with IDs when using claim_sets', () {
      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {'name': 'Alice', 'email': 'alice@example.com'},
      );

      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred1',
            format: CredentialFormat.ldpVc,
            claims: [
              // All claims must have IDs when claim_sets is present
              DcqlClaim(
                id: 'name',
                path: ['credentialSubject', 'name'],
                values: ['Alice'],
              ),
              // Claim with ID that can be used in claim_sets
              DcqlClaim(
                id: 'email',
                path: ['credentialSubject', 'email'],
                values: ['alice@example.com'],
              ),
            ],
            claimSets: [
              ['email'], // Only requires the email claim with ID
            ],
          ),
        ],
      );

      final result = query.query([vc]);
      expect(result.verifiableCredentials['cred1']?.isNotEmpty, isTrue);
      expect(result.fulfilled, isTrue);
    });

    test('should match credential with only claims without ID', () {
      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {'name': 'Alice', 'age': 30},
      );

      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred1',
            format: CredentialFormat.ldpVc,
            claims: [
              // All claims without IDs
              DcqlClaim(
                path: ['credentialSubject', 'name'],
                values: ['Alice'],
              ),
              DcqlClaim(
                path: ['credentialSubject', 'age'],
                values: [30],
              ),
            ],
          ),
        ],
      );

      final result = query.query([vc]);
      expect(result.verifiableCredentials['cred1']?.isNotEmpty, isTrue);
      expect(result.fulfilled, isTrue);
    });
  });
}
