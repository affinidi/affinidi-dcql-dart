import 'package:dcql/src/dcql_base.dart';

import 'helpers/vc_test_data.dart';

void main() async {
  final credential1 =
      await VcTestData.createW3CCredentialV2(credentialSubject: {
    'given_name': 'Alice',
    'family_name': 'Doe',
    'citizenship': [
      {'country': 'Germany'},
    ],
  }, types: [
    'VerifiableCredential',
    'UniversityDegreeCredential'
  ]);

  final credential2 = await VcTestData.createW3CCredentialV2(
    credentialSubject: {
      'given_name': 'Alice',
      'family_name': 'Doe',
      'address': [
        {'country': 'Singapore'},
      ],
    },
    types: ['VerifiableCredential', 'UniversityDegreeCredential'],
  );

  final query = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'credential_a',
        format: CredentialFormat.ldpVc,
        claims: [
          DcqlClaim(
              path: ['credentialSubject', 'given_name'], id: 'given_name'),
          DcqlClaim(
              path: ['credentialSubject', 'family_name'], id: 'family_name'),
          DcqlClaim(
            path: ['credentialSubject', 'citizenship', null, 'country'],
            values: ['Germany'],
            id: 'citizenship',
          ),
        ],
      ),
      DcqlCredential(
        id: 'credential_b',
        format: CredentialFormat.ldpVc,
        claims: [
          DcqlClaim(
              path: ['credentialSubject', 'given_name'], id: 'given_name'),
          DcqlClaim(
              path: ['credentialSubject', 'family_name'], id: 'family_name'),
          DcqlClaim(
            path: ['credentialSubject', 'address', null, 'country'],
            values: ['Singapore'],
            id: 'address_country',
          ),
        ],
      ),
    ],
    credentialSets: [
      DcqlCredentialSet(
        options: [
          ['credential_a'],
          ['credential_b'],
        ],
      ),
    ],
  );
  final digitalCredentials = [credential1, credential2];
  final result = query.query(digitalCredentials);

  print('Fulfilled: ${result.fulfilled}');
  print('Matched credentials: ${result.verifiableCredentials.keys}');
}
