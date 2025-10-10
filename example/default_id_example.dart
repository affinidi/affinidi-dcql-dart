import 'package:dcql/dcql.dart';
import '../test/helpers/vc_test_data.dart';

void main() {
  // Create a query with mixed claim IDs
  final query = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'identity_credential',
        format: CredentialFormat.ldpVc,
        claims: [
          // Claim with explicit ID
          DcqlClaim(
            id: 'user_name',
            path: ['credentialSubject', 'name'],
          ),
          // Claim without ID - should get default ID CLAIM_1
          DcqlClaim(
            path: ['credentialSubject', 'email'],
          ),
          // Claim with explicit ID
          DcqlClaim(
            id: 'age_claim',
            path: ['credentialSubject', 'age'],
          ),
          // Claim without ID that will NOT be satisfied - should get default ID CLAIM_3
          DcqlClaim(
            path: ['credentialSubject', 'socialSecurityNumber'],
          ),
        ],
      ),
    ],
  );

  // Create a test credential that satisfies some but not all claims
  final credential = VcTestData.createW3CCredential(
    types: ['VerifiableCredential', 'IdentityCredential'],
    credentialSubject: {
      'name': 'Alice Smith',
      'email': 'alice.smith@example.com',
      'age': 28,
      // Note: 'socialSecurityNumber' is intentionally missing
    },
  );

  print('Query Details:');
  print('Credential ID: identity_credential');
  print('Claims:');
  print('1. user_name (explicit ID) -> credentialSubject.name');
  print('2. CLAIM_1 (default ID) -> credentialSubject.email');
  print('3. age_claim (explicit ID) -> credentialSubject.age');
  print('4. CLAIM_3 (default ID) -> credentialSubject.socialSecurityNumber');

  print('Credential Data:');
  print('-name: "Alice Smith"');
  print('-email: "alice.smith@example.com"');
  print('-age: 28');
  print('-socialSecurityNumber: <missing>');

  final result = query.query([credential]);

  print('Query Results:');
  print('-Overall Fulfilled: ${result.fulfilled}');
  print('-Meta Fulfilled: ${result.metaFulfilled}');
  print(
      '-Matched Credentials: ${result.verifiableCredentials.keys.join(', ')}');

  print('Satisfied Claims:');
  final satisfiedClaims =
      result.satisfiedClaimsByCredential['identity_credential'];
  if (satisfiedClaims != null && satisfiedClaims.isNotEmpty) {
    final flatSatisfied = satisfiedClaims.expand((set) => set).toSet();
    for (final claimId in flatSatisfied) {
      String description;
      switch (claimId) {
        case 'user_name':
          description = 'User name (explicit ID)';
          break;
        case 'CLAIM_1':
          description = 'Email (auto-generated ID)';
          break;
        case 'age_claim':
          description = 'Age (explicit ID)';
          break;
        default:
          description = 'Unknown claim';
      }
      print('  ✓ $claimId: $description');
    }
  } else {
    print('None');
  }

  // Show unsatisfied claims
  print('Unsatisfied Claims:');
  final unsatisfiedClaims =
      result.unsatisfiedClaimsByCredential['identity_credential'];
  if (unsatisfiedClaims != null && unsatisfiedClaims.isNotEmpty) {
    final flatUnsatisfied = unsatisfiedClaims.expand((set) => set).toSet();
    for (final claimId in flatUnsatisfied) {
      String description;
      switch (claimId) {
        case 'CLAIM_3':
          description = 'Social Security Number (auto-generated ID)';
          break;
        default:
          description = 'Unknown claim';
      }
      print('  ✗ $claimId: $description');
    }
  } else {
    print('None');
  }
}
