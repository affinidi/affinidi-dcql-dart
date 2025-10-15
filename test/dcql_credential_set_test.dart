import 'package:dcql/src/dcql_credential_set/dcql_credential_set.dart';
import 'package:test/test.dart';

void main() {
  group('DcqlCredentialSet', () {
    test('should create with required parameters', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
          ['license', 'birth_cert'],
        ],
      );

      expect(credentialSet.options, hasLength(2));
      expect(credentialSet.options.first, ['passport']);
      expect(credentialSet.options.last, ['license', 'birth_cert']);
      expect(credentialSet.required, isTrue);
    });

    test('should create with required set to false', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
        ],
        required: false,
      );

      expect(credentialSet.options, hasLength(1));
      expect(credentialSet.required, isFalse);
    });

    test('should create with single option', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
        ],
      );

      expect(credentialSet.options, hasLength(1));
      expect(credentialSet.options.first, ['passport']);
    });

    test('should create with multiple options', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
          ['license', 'birth_cert'],
          ['national_id'],
        ],
      );

      expect(credentialSet.options, hasLength(3));
      expect(credentialSet.options[0], ['passport']);
      expect(credentialSet.options[1], ['license', 'birth_cert']);
      expect(credentialSet.options[2], ['national_id']);
    });

    test('should serialize to JSON correctly', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
          ['license', 'birth_cert'],
        ],
        required: false,
      );

      final json = credentialSet.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['options'], isA<List>());
      expect(json['options'], hasLength(2));
      expect(json['required'], isFalse);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'options': [
          ['passport'],
          ['license', 'birth_cert'],
        ],
        'required': true,
      };

      final credentialSet = DcqlCredentialSet.fromJson(json);

      expect(credentialSet.options, hasLength(2));
      expect(credentialSet.options.first, ['passport']);
      expect(credentialSet.options.last, ['license', 'birth_cert']);
      expect(credentialSet.required, isTrue);
    });

    test('should preserve data in round-trip serialization', () {
      final original = DcqlCredentialSet(
        options: [
          ['passport'],
          ['license', 'birth_cert'],
          ['national_id'],
        ],
        required: false,
      );

      final json = original.toJson();
      final deserialized = DcqlCredentialSet.fromJson(json);

      expect(deserialized.options, original.options);
      expect(deserialized.required, original.required);
    });

    test('should handle empty options list', () {
      final credentialSet = DcqlCredentialSet(options: []);

      expect(credentialSet.options, isEmpty);
      expect(credentialSet.required, isTrue);
    });

    test('should handle options with single credential', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['passport'],
        ],
      );

      expect(credentialSet.options.first, hasLength(1));
      expect(credentialSet.options.first.first, 'passport');
    });

    test('should handle options with multiple credentials', () {
      final credentialSet = DcqlCredentialSet(
        options: [
          ['license', 'birth_cert', 'social_security'],
        ],
      );

      expect(credentialSet.options.first, hasLength(3));
      expect(credentialSet.options.first, contains('license'));
      expect(credentialSet.options.first, contains('birth_cert'));
      expect(credentialSet.options.first, contains('social_security'));
    });
  });
}
