import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:dcql/src/dcql_credential/dcql_credential.dart';
import 'package:dcql/src/dcql_credential_query/dcql_credential_query.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('Default ID Implementation', () {
    test('should generate default IDs for claims without explicit IDs', () {
      final claim1 = DcqlClaim(path: ['credentialSubject', 'name']);
      final claim2 = DcqlClaim(path: ['credentialSubject', 'email']);
      final claim3 =
          DcqlClaim(id: 'explicit_id', path: ['credentialSubject', 'age']);

      expect(claim1.getEffectiveId(0), 'CLAIM_0');
      expect(claim2.getEffectiveId(1), 'CLAIM_1');
      expect(claim3.getEffectiveId(2), 'explicit_id');
    });

    test('should capture both satisfied and unsatisfied claims in query result',
        () {
      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'test_cred',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(
                  path: ['credentialSubject', 'name']), // Will get CLAIM_0
              DcqlClaim(
                  path: ['credentialSubject', 'email']), // Will get CLAIM_1
              DcqlClaim(
                  id: 'age_claim',
                  path: ['credentialSubject', 'age']), // Explicit ID
              DcqlClaim(path: [
                'credentialSubject',
                'nonexistent'
              ]), // Will get CLAIM_3 and be unsatisfied
            ],
          ),
        ],
      );

      // Create a test credential that has name, email, age but not 'nonexistent'
      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'TestCredential'],
        credentialSubject: {
          'name': 'John Doe',
          'email': 'john@example.com',
          'age': 30,
          // 'nonexistent' field is missing
        },
      );

      final result = query.query([vc]);

      // Check that we have both satisfied and unsatisfied claims
      expect(result.satisfiedClaimsByCredential.isNotEmpty, true);
      expect(result.unsatisfiedClaimsByCredential.isNotEmpty, true);

      final satisfiedClaims = result.satisfiedClaimsByCredential['test_cred'];
      final unsatisfiedClaims =
          result.unsatisfiedClaimsByCredential['test_cred'];

      expect(satisfiedClaims, isNotNull);
      expect(unsatisfiedClaims, isNotNull);

      final flatSatisfied = satisfiedClaims!.expand((set) => set).toSet();
      expect(flatSatisfied.contains('CLAIM_0'), true,
          reason: 'Should contain default ID for name claim');
      expect(flatSatisfied.contains('CLAIM_1'), true,
          reason: 'Should contain default ID for email claim');
      expect(flatSatisfied.contains('age_claim'), true,
          reason: 'Should contain explicit ID for age claim');

      final flatUnsatisfied = unsatisfiedClaims!.expand((set) => set).toSet();
      expect(flatUnsatisfied.contains('CLAIM_3'), true,
          reason: 'Should contain default ID for nonexistent claim');
    });

    test('should handle claim sets with explicit IDs correctly', () {
      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'test_cred',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(id: 'name_id', path: ['credentialSubject', 'name']),
              DcqlClaim(id: 'email_id', path: ['credentialSubject', 'email']),
              DcqlClaim(id: 'age_id', path: ['credentialSubject', 'age']),
            ],
            claimSets: [
              ['name_id', 'email_id'], // Both have explicit IDs
            ],
          ),
        ],
      );

      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'TestCredential'],
        credentialSubject: {
          'name': 'John Doe',
          'email': 'john@example.com',
          'age': 30,
        },
      );

      final result = query.query([vc]);

      expect(result.fulfilled, true,
          reason: 'Query should be fulfilled when claim set is satisfied');

      final satisfiedClaims = result.satisfiedClaimsByCredential['test_cred'];
      expect(satisfiedClaims, isNotNull);

      final flatSatisfied = satisfiedClaims!.expand((set) => set).toSet();
      expect(flatSatisfied.contains('name_id'), true);
      expect(flatSatisfied.contains('email_id'), true);
      expect(flatSatisfied.contains('age_id'), true);
    });

    test('should track unsatisfied claims when credential does not match', () {
      final query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'missing_cred',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(path: ['credentialSubject', 'nonexistent1']), // CLAIM_0
              DcqlClaim(path: ['credentialSubject', 'nonexistent2']), // CLAIM_1
            ],
          ),
        ],
      );

      final vc = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'TestCredential'],
        credentialSubject: {
          'name': 'John Doe',
          // Missing the fields we're looking for
        },
      );

      final result = query.query([vc]);

      expect(result.fulfilled, false,
          reason: 'Query should not be fulfilled when no claims match');
      expect(result.unsatisfiedClaimsByCredential.isNotEmpty, true);

      final unsatisfiedClaims =
          result.unsatisfiedClaimsByCredential['missing_cred'];
      expect(unsatisfiedClaims, isNotNull);

      final flatUnsatisfied = unsatisfiedClaims!.expand((set) => set).toSet();
      expect(flatUnsatisfied.contains('CLAIM_0'), true);
      expect(flatUnsatisfied.contains('CLAIM_1'), true);
    });
  });
}
