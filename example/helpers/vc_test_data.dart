import 'dart:typed_data';

import 'package:dcql/src/digital_credential/w3c/credential/w3c_digital_credential.dart';
import 'package:ssi/ssi.dart';

import 'init_did_signer.dart';

/// Helper class for creating test W3C Verifiable Credentials
class VcTestData {
  static Map<String, dynamic> createV1TestVCPayload({
    List<String> types = const ['VerifiableCredential'],
    required Map<String, dynamic> credentialSubject,
    String? id,
    String? issuer,
    String? issuanceDate,
    Map<String, dynamic>? proof,
  }) {
    final now = DateTime.now();
    final timestamp = issuanceDate ?? '2025-01-01T00:00:00Z';
    final issuerId = issuer ?? 'did:example:issuer';

    return {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': types,
      'issuer': issuerId,
      'issuanceDate': timestamp,
      'credentialSubject': credentialSubject,
      'id': id ?? 'urn:uuid:test-${now.millisecondsSinceEpoch}',
      'proof': proof ??
          {
            'type': 'EcdsaSecp256k1Signature2019',
            'created': timestamp,
            'verificationMethod': '$issuerId#key-1',
            'proofPurpose': 'assertionMethod',
            'jws': 'eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ..signature'
          }
    };
  }

  static Map<String, dynamic> createV2TestVCPayload({
    List<String> types = const ['VerifiableCredential'],
    required Map<String, dynamic> credentialSubject,
    String? id,
    String? issuer,
    String? validFrom,
  }) {
    final now = DateTime.now();
    final timestamp = validFrom ?? '2025-01-01T00:00:00Z';
    final issuerId = issuer ?? 'did:example:issuer';

    return {
      '@context': ['https://www.w3.org/ns/credentials/v2'],
      'type': types,
      'issuer': issuerId,
      'validFrom': timestamp,
      'credentialSubject': credentialSubject,
      'id': id ?? 'urn:uuid:test-v2-${now.millisecondsSinceEpoch}',
    };
  }

  static W3CDigitalCredential createW3CCredentialV1({
    List<String> types = const ['VerifiableCredential'],
    required Map<String, dynamic> credentialSubject,
    String? id,
    String? issuer,
    String? issuanceDate,
    Map<String, dynamic>? proof,
  }) {
    final vcData = createV1TestVCPayload(
      types: types,
      credentialSubject: credentialSubject,
      id: id,
      issuer: issuer,
      issuanceDate: issuanceDate,
      proof: proof,
    );
    return W3CDigitalCredential.fromLdVcDataModelV1(vcData);
  }

  /// Creates a W3CDigitalCredential v2.0 from test data
  static W3CDigitalCredential createW3CCredentialV2({
    List<String> types = const ['VerifiableCredential'],
    required Map<String, dynamic> credentialSubject,
    String? id,
    String? issuer,
    String? validFrom,
  }) {
    final vcData = createV2TestVCPayload(
      types: types,
      credentialSubject: credentialSubject,
      id: id,
      issuer: issuer,
      validFrom: validFrom,
    );
    return W3CDigitalCredential.fromLdVcDataModelV2(vcData);
  }

  // SD-JWT
  static Future<SdJwtDataModelV2> createSdJwtDataModelV2({
    required Map<String, dynamic> credentialSubject,
    required Map<String, dynamic> disclosureFrame,
    required String type,
  }) async {
    // Example seed for deterministic key generation
    final seed = Uint8List.fromList(List.generate(32, (i) => i + 1));

    final signer = await initSigner(seed);

    final mutableVC = MutableVcDataModelV2(
      context: [dmV2ContextUrl],
      id: Uri.parse('urn:uuid:1234abcd-1234-abcd-1234-abcd1234abcd'),
      issuer: Issuer.uri(signer.did),
      type: {'VerifiableCredential', type},
      validFrom: DateTime.parse('2023-01-01T12:00:00Z'),
      validUntil: DateTime.parse('2028-01-01T12:00:00Z'),
      credentialSubject: [
        MutableCredentialSubject(
          credentialSubject,
        )
      ],
    );

    final suite = SdJwtDm2Suite();
    final issuedCredential = await suite.issue(
      unsignedData: VcDataModelV2.fromMutable(mutableVC),
      signer: signer,
      disclosureFrame: disclosureFrame,
    );

    return issuedCredential;
  }
}
