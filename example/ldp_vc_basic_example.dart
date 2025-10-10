import 'package:dcql/src/dcql_base.dart';
import 'package:ssi/ssi.dart';

void main() async {
  final verifiableCredentials = [
    VcDataModelV1.fromJson({
      '@context': [
        'https://www.w3.org/2018/credentials/v1',
        'https://schema.affinidi.io/TEmailV1R0.jsonld',
      ],
      'credentialSchema': {
        'id': 'https://schema.affinidi.io/TEmailV1R0.json',
        'type': 'JsonSchemaValidator2018',
      },
      'credentialSubject': {'email': 'alice.doe@test.com'},
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
      'type': ['VerifiableCredential', 'Email'],
    }),
  ];

  final query = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'pid',
        format: CredentialFormat.ldpVc,
        meta: DcqlMeta.forW3C(typeValues: [
          ['Email']
        ]),
        claims: [
          DcqlClaim(
            id: 'email',
            path: ['credentialSubject', 'email'],
            values: ['alice.doe@test.com'],
          ),
        ],
      ),
    ],
  );

  final digitalCredentials = verifiableCredentials.map((vc) {
    return W3CDigitalCredential.fromLdVcDataModelV1(
      vc.toJson(),
    );
  }).toList();
  final result = query.query(digitalCredentials);
  print('Query email');
  print('Fulfilled: ${result.fulfilled}');
  print('Meta is fulfilled: ${result.metaFulfilled}');
  print('Satisfied Meta: ${result.satisfiedMeta}');
  print('Satisfied Claims: ${result.satisfiedClaimsByCredential}');
  print('VCs: ${result.verifiableCredentials}');

  final issuerQuery = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'pid',
        format: CredentialFormat.ldpVc,
        claims: [
          DcqlClaim(
            id: 'issuer',
            path: ['issuer', 'id'],
            values: [
              'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6'
            ],
          ),
        ],
      ),
    ],
  );
  final issuerResult = issuerQuery.query(digitalCredentials);
  print('Query issuer');
  print('Fulfilled: ${issuerResult.fulfilled}');
  print('Satisfied Claims: ${issuerResult.satisfiedClaimsByCredential}');
  print('VCs: ${issuerResult.verifiableCredentials}');
}
