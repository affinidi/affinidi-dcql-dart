import 'package:dcql/src/dcql_base.dart';
import 'package:selective_disclosure_jwt/selective_disclosure_jwt.dart';

import 'helpers/consts.dart';

void main() async {
  final signedJwt = await SdJwtHandlerV1().sign(
    claims: {
      'given_name': 'Alice',
      'family_name': 'Doe',
      'address': {'street_address': '123 Main St'},
      'email': 'alice.doe@test.com',
      'citizenship': [
        {'country': 'Singapore'},
        {'country': 'Germany'},
      ],
      'education': [
        {'masterDegree': 'Computer Science'},
      ],
    },
    disclosureFrame: {
      '_sd': [
        'given_name',
        'family_name',
        'address',
        'citizenship',
        'education'
      ],
    },
    holderPublicKey: SdPublicKey(holderPublicKeyPem, SdJwtSignAlgorithm.es256k),
    signer: SDKeySigner(
      SdPrivateKey(issuerPrivateKeyPem, SdJwtSignAlgorithm.es256k),
    ),
  );

  final query = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'pid',
        format: CredentialFormat.dcSdJwt,
        claims: [
          DcqlClaim(
              id: 'given_name', path: ['given_name'], values: ['Alice', 'Bob']),
          DcqlClaim(id: 'family_name', path: ['family_name']),
          DcqlClaim(id: 'street_address', path: ['address', 'street_address']),
          DcqlClaim(
            id: 'citizenship',
            path: ['citizenship', null, 'country'],
            values: ['Germany'],
          ),
          DcqlClaim(
            id: 'masterDegree',
            path: ['education', 0, 'masterDegree'],
            values: ['Computer Science'],
          ),
        ],
      ),
    ],
  );

  // Wrap signed SD-JWT into library's DigitalCredential abstraction
  final digitalCredentials = [
    SdJwtDigitalCredential.fromSdJwt(sdJwtToken: signedJwt.serialized)
  ];
  final result = query.query(digitalCredentials);

  print('Fulfilled: ${result.fulfilled}');
  print(
      'Satisfied Claims by Credential: ${result.satisfiedClaimsByCredential}');
  print('Matched credentials: ${result.verifiableCredentials}');
}
