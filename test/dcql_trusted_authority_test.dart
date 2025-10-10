import 'package:dcql/src/dcql_trusted_authority/dcql_trusted_authority.dart';
import 'package:dcql/src/trusted_authority_type/trusted_authority_type.dart';
import 'package:test/test.dart';

void main() {
  group('DcqlTrustedAuthority', () {
    test('should create with required parameters', () {
      final authority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.aki,
        values: ['did:example:issuer1', 'did:example:issuer2'],
      );

      expect(authority.type, TrustedAuthorityType.aki);
      expect(authority.values, hasLength(2));
      expect(authority.values, contains('did:example:issuer1'));
      expect(authority.values, contains('did:example:issuer2'));
    });

    test('should create with single value', () {
      final authority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.etsiTl,
        values: ['https://trust-framework.example.com'],
      );

      expect(authority.type, TrustedAuthorityType.etsiTl);
      expect(authority.values, hasLength(1));
      expect(authority.values.first, 'https://trust-framework.example.com');
    });

    test('should create with empty values list', () {
      final authority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.aki,
        values: [],
      );

      expect(authority.type, TrustedAuthorityType.aki);
      expect(authority.values, isEmpty);
    });

    test('should serialize to JSON correctly', () {
      final authority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.aki,
        values: ['did:example:issuer1', 'did:example:issuer2'],
      );

      final json = authority.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['type'], 'aki');
      expect(json['values'], isA<List>());
      expect(json['values'], hasLength(2));
      expect(json['values'], contains('did:example:issuer1'));
      expect(json['values'], contains('did:example:issuer2'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'type': 'etsi_tl',
        'values': [
          'https://trust-framework.example.com',
          'https://another-framework.example.com'
        ],
      };

      final authority = DcqlTrustedAuthority.fromJson(json);

      expect(authority.type, TrustedAuthorityType.etsiTl);
      expect(authority.values, hasLength(2));
      expect(authority.values, contains('https://trust-framework.example.com'));
      expect(
          authority.values, contains('https://another-framework.example.com'));
    });

    test('should preserve data in round-trip serialization', () {
      final original = DcqlTrustedAuthority(
        type: TrustedAuthorityType.aki,
        values: [
          'did:example:issuer1',
          'did:example:issuer2',
          'did:example:issuer3'
        ],
      );

      final json = original.toJson();
      final deserialized = DcqlTrustedAuthority.fromJson(json);

      expect(deserialized.type, original.type);
      expect(deserialized.values, original.values);
    });

    test('should handle different authority types', () {
      final issuerAuthority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.aki,
        values: ['did:example:issuer'],
      );

      final frameworkAuthority = DcqlTrustedAuthority(
        type: TrustedAuthorityType.etsiTl,
        values: ['https://trust-framework.example.com'],
      );

      expect(issuerAuthority.type, TrustedAuthorityType.aki);
      expect(frameworkAuthority.type, TrustedAuthorityType.etsiTl);
    });
  });
}
