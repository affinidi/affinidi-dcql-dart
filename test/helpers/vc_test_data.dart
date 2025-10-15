import 'package:dcql/src/digital_credential/w3c/credential/w3c_digital_credential.dart';

/// Helper class for creating test W3C Verifiable Credentials
class VcTestData {
  static Map<String, dynamic> createTestVC({
    List<String> types = const ['VerifiableCredential'],
    Map<String, dynamic>? credentialSubject,
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
      'credentialSubject':
          credentialSubject ??
          {
            'id': 'did:example:holder',
            'name': 'Test User',
            'email': 'test@example.com',
          },
      'id': id ?? 'urn:uuid:test-${now.millisecondsSinceEpoch}',
      'proof':
          proof ??
          {
            'type': 'EcdsaSecp256k1Signature2019',
            'created': timestamp,
            'verificationMethod': '$issuerId#key-1',
            'proofPurpose': 'assertionMethod',
            'jws': 'eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ..signature',
          },
    };
  }

  static Map<String, dynamic> createEmailVC({
    String? email,
    String? name,
    String? id,
    String? issuer,
  }) {
    return createTestVC(
      types: ['VerifiableCredential', 'EmailCredential'],
      credentialSubject: {
        'id': 'did:example:holder',
        'name': name ?? 'Alice Smith',
        'email': email ?? 'alice@example.com',
      },
      id: id,
      issuer: issuer,
    );
  }

  static Map<String, dynamic> createPersonVC({
    String? name,
    String? email,
    List<Map<String, dynamic>>? addresses,
    List<Map<String, dynamic>>? citizenship,
    String? id,
    String? issuer,
  }) {
    return createTestVC(
      types: ['VerifiableCredential', 'PersonCredential'],
      credentialSubject: {
        'id': 'did:example:holder',
        'name': name ?? 'Alice Smith',
        'email': email ?? 'alice@example.com',
        if (addresses != null) 'addresses': addresses,
        if (citizenship != null) 'citizenship': citizenship,
      },
      id: id,
      issuer: issuer,
    );
  }

  static Map<String, dynamic> createComplexVC({
    String? name,
    String? email,
    List<String>? skills,
    Map<String, dynamic>? address,
    String? id,
    String? issuer,
  }) {
    return createTestVC(
      types: ['VerifiableCredential', 'PersonCredential'],
      credentialSubject: {
        'id': 'did:example:holder',
        'name': name ?? 'Alice Smith',
        'email': email ?? 'alice@example.com',
        if (skills != null) 'skills': skills,
        if (address != null) 'address': address,
      },
      id: id,
      issuer: issuer,
    );
  }

  static Map<String, dynamic> createV2TestVC({
    List<String> types = const ['VerifiableCredential'],
    Map<String, dynamic>? credentialSubject,
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
      'credentialSubject':
          credentialSubject ??
          {
            'id': 'did:example:holder',
            'name': 'Test User',
            'email': 'test@example.com',
          },
      'id': id ?? 'urn:uuid:test-v2-${now.millisecondsSinceEpoch}',
    };
  }

  static W3CDigitalCredential createW3CCredential({
    List<String> types = const ['VerifiableCredential'],
    Map<String, dynamic>? credentialSubject,
    String? id,
    String? issuer,
    String? issuanceDate,
    Map<String, dynamic>? proof,
  }) {
    final vcData = createTestVC(
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
    Map<String, dynamic>? credentialSubject,
    String? id,
    String? issuer,
    String? validFrom,
  }) {
    final vcData = createV2TestVC(
      types: types,
      credentialSubject: credentialSubject,
      id: id,
      issuer: issuer,
      validFrom: validFrom,
    );
    return W3CDigitalCredential.fromLdVcDataModelV2(vcData);
  }

  static W3CDigitalCredential createNestedArrayTestCredential({
    String? id,
    String? issuer,
  }) {
    return createW3CCredential(
      types: ['VerifiableCredential', 'PersonCredential'],
      credentialSubject: {
        'id': 'did:example:holder',
        'name': 'Alice Smith',
        'email': 'alice@example.com',
        'addresses': [
          {'street': '123 Main St', 'city': 'New York', 'country': 'USA'},
          {'street': '456 Oak Ave', 'city': 'Los Angeles', 'country': 'USA'},
        ],
        'citizenship': [
          {'country': 'USA', 'status': 'citizen'},
          {'country': 'Canada', 'status': 'permanent_resident'},
        ],
      },
      id: id ?? 'urn:uuid:test-vc',
      issuer: issuer,
    );
  }
}
