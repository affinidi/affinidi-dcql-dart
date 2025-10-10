import 'package:dcql/dcql.dart';

import 'helpers/vc_test_data.dart';

void main() async {
  final credential = await VcTestData.createW3CCredentialV2(credentialSubject: {
    'given_name': 'Alice',
    'family_name': 'Doe',
    'citizenship': [
      {'country': 'Germany'},
    ],
  }, types: [
    'VerifiableCredential',
    'UniversityDegreeCredential'
  ]);

  // Query: either (a,b,c) OR (a,b,d) must be satisfied by a single credential
  final query = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'pid',
        format: CredentialFormat.ldpVc,
        claims: [
          DcqlClaim(
            id: 'claim_a',
            path: ['credentialSubject', 'given_name'],
            values: ['Alice', 'Bob'],
          ),
          DcqlClaim(id: 'claim_b', path: ['credentialSubject', 'family_name']),
          DcqlClaim(
              id: 'claim_c', path: ['credentialSubject', 'address', 'country']),
          DcqlClaim(
            id: 'claim_d',
            path: ['credentialSubject', 'citizenship', null, 'country'],
            values: ['Germany'],
          ),
        ],
        claimSets: [
          ['claim_a', 'claim_b', 'claim_c'],
          ['claim_a', 'claim_b', 'claim_d'],
        ],
      ),
    ],
  );
  final result = query.query([credential]);

  print('Fulfilled: ${result.fulfilled}');
  print('Matched credentials: ${result.verifiableCredentials.keys}');
}
