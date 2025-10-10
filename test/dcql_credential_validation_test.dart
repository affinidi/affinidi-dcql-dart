import 'package:dcql/src/dcql_credential/dcql_credential.dart';
import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:dcql/src/dcql_meta/dcql_meta.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:test/test.dart';

void main() {
  group('DcqlCredential validation', () {
    group('id validation', () {
      test('should pass with valid alphanumeric id', () {
        final cred = DcqlCredential(
          id: 'validId123',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid id containing underscores', () {
        final cred = DcqlCredential(
          id: 'valid_id_123',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid id containing hyphens', () {
        final cred = DcqlCredential(
          id: 'valid-id-123',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with mixed valid characters', () {
        final cred = DcqlCredential(
          id: 'Valid_ID-123',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with empty id', () {
        final cred = DcqlCredential(
          id: '',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.'));
      });

      test('should fail with id containing spaces', () {
        final cred = DcqlCredential(
          id: 'invalid id',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.'));
      });

      test('should fail with id containing special characters', () {
        final cred = DcqlCredential(
          id: 'invalid@id!',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.'));
      });

      test('should fail with id containing dots', () {
        final cred = DcqlCredential(
          id: 'invalid.id',
          format: CredentialFormat.ldpVc,
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.'));
      });
    });

    group('claimSets vs claims validation', () {
      test('should pass when both claims and claimSets are null', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: null,
          claimSets: null,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass when claims is provided and claimSets is null', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(id: 'name', path: ['name']),
          ],
          claimSets: null,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass when both claims and claimSets are provided', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(id: 'name', path: ['name']),
            DcqlClaim(id: 'age', path: ['age']),
          ],
          claimSets: [
            ['name', 'age'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail when claimSets is provided but claims is null', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: null,
          claimSets: [
            ['name', 'age'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('claimSets is provided but claims is null or empty.'));
      });

      test('should fail when claimSets is provided but claims is empty', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [],
          claimSets: [
            ['name', 'age'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('claimSets is provided but claims is null or empty.'));
      });
    });

    group('meta validation', () {
      test('should pass when meta is null', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          meta: null,
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid W3C meta', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          meta: DcqlMeta.forW3C(typeValues: [
            ['PersonCredential']
          ]),
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid SD-JWT meta', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.dcSdJwt,
          meta: DcqlMeta.forDcSdJwt(vctValues: ['person_credential']),
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with invalid meta for format', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.dcSdJwt,
          meta: DcqlMeta(), // Invalid for SD-JWT format
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('vct_values')), isTrue);
      });
    });

    group('claims validation', () {
      test('should pass with valid claims', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(id: 'name', path: ['name'], values: ['Alice']),
            DcqlClaim(id: 'age', path: ['age'], values: [30]),
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with invalid claims', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(id: '', path: []), // Invalid claim
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors
                .any((e) => e.contains('id must be a non-empty string')),
            isTrue);
        expect(
            result.errors
                .any((e) => e.contains('path must be a non-empty array')),
            isTrue);
      });

      test('should propagate claim validation errors with claimSets', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(
                id: null, path: ['name']), // Invalid when claimSets present
          ],
          claimSets: [
            ['name'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors.any(
                (e) => e.contains('id is required when claim_sets is present')),
            isTrue);
      });
    });

    group('combined validation scenarios', () {
      test('should accumulate multiple validation errors', () {
        final cred = DcqlCredential(
          id: '', // Invalid id
          format: CredentialFormat.dcSdJwt,
          meta: DcqlMeta(), // Invalid meta for SD-JWT
          claims: null,
          claimSets: [
            ['name'], // ClaimSets without claims
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, hasLength(3));
        expect(
            result.errors,
            contains(
                'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.'));
        expect(result.errors,
            contains('claimSets is provided but claims is null or empty.'));
        expect(result.errors.any((e) => e.contains('vct_values')), isTrue);
      });

      test('should pass when all constraints are satisfied', () {
        final cred = DcqlCredential(
          id: 'valid-credential-123',
          format: CredentialFormat.ldpVc,
          meta: DcqlMeta.forW3C(typeValues: [
            ['PersonCredential']
          ]),
          claims: [
            DcqlClaim(id: 'name', path: ['credentialSubject', 'name']),
            DcqlClaim(id: 'age', path: ['credentialSubject', 'age']),
          ],
          claimSets: [
            ['name', 'age'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should validate complex claims with duplicate ids', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(id: 'duplicate', path: ['name']),
            DcqlClaim(id: 'duplicate', path: ['surname']),
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors.any((e) => e.contains(
                'id must not be present more than once in claims array')),
            isTrue);
      });

      test('should validate claims with invalid values and claimSets', () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(
                id: 'invalid',
                path: ['name'],
                values: [3.14]), // Invalid value type
          ],
          claimSets: [
            ['invalid'],
          ],
        );
        final result = cred.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors.any((e) => e.contains(
                'values must be an array of strings, integers or boolean values')),
            isTrue);
      });
    });

    group('format specific validation', () {
      test('should validate across different formats', () {
        final formats = [
          CredentialFormat.ldpVc,
          CredentialFormat.dcSdJwt,
          CredentialFormat.jwtVcJson,
          CredentialFormat.msoMdoc,
          CredentialFormat.acVp,
        ];

        for (final format in formats) {
          final cred = DcqlCredential(
            id: 'test-${format.name}',
            format: format,
          );
          final result = cred.validate();
          expect(result.isValid, isTrue,
              reason: 'Format ${format.name} should validate successfully');
        }
      });
    });
  });
}
