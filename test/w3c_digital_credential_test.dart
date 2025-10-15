import 'package:dcql/src/digital_credential/w3c/credential/w3c_digital_credential.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:dcql/src/digital_credential/w3c/meta/w3c_meta.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('W3CDigitalCredential', () {
    late W3CDigitalCredential credential;

    setUp(() {
      credential = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {
          'id': 'did:example:holder',
          'name': 'Alice Smith',
          'email': 'alice@example.com',
        },
        id: 'urn:uuid:test-vc',
      );
    });

    test('format is ldpVc', () {
      expect(credential.format, CredentialFormat.ldpVc);
    });

    test('should return W3cMeta with correct types and contexts', () {
      final meta = credential.meta;
      expect(meta, isA<W3cMeta>());
      expect(meta.types, contains('VerifiableCredential'));
      expect(meta.types, contains('PersonCredential'));
      expect(meta.contexts, contains('https://www.w3.org/2018/credentials/v1'));
    });

    group('getValueByPath', () {
      test('should extract simple nested values', () {
        final email = credential.getValueByPath(['credentialSubject', 'email']);
        expect(email, 'alice@example.com');

        final name = credential.getValueByPath(['credentialSubject', 'name']);
        expect(name, 'Alice Smith');
      });

      test('should extract values from arrays with specific index', () {
        final complexCredential = VcTestData.createNestedArrayTestCredential();

        final firstAddress = complexCredential.getValueByPath([
          'credentialSubject',
          'addresses',
          0,
          'city',
        ]);
        expect(firstAddress, 'New York');

        final secondAddress = complexCredential.getValueByPath([
          'credentialSubject',
          'addresses',
          1,
          'city',
        ]);
        expect(secondAddress, 'Los Angeles');
      });

      test('should return null for non-existent paths', () {
        final result = credential.getValueByPath([
          'credentialSubject',
          'nonExistent',
        ]);
        expect(result, isNull);

        final complexCredential = VcTestData.createNestedArrayTestCredential();

        final result2 = complexCredential.getValueByPath([
          'credentialSubject',
          'addresses',
          5,
          'city',
        ]);
        expect(result2, isNull);
      });

      test('should return null for invalid array index', () {
        final complexCredential = VcTestData.createNestedArrayTestCredential();

        final result = complexCredential.getValueByPath([
          'credentialSubject',
          'addresses',
          -1,
          'city',
        ]);
        expect(result, isNull);
      });

      test('should handle empty path', () {
        final result = credential.getValueByPath([]);
        expect(result, isNotNull);
        expect(result, isA<Map>());
      });

      test('should extract top-level properties', () {
        final issuer = credential.getValueByPath(['issuer']);
        expect(issuer, isA<Map>());

        final id = credential.getValueByPath(['id']);
        expect(id, 'urn:uuid:test-vc');
      });

      test('should handle complex nested structures', () {
        final complexCredential = VcTestData.createNestedArrayTestCredential();

        final status = complexCredential.getValueByPath([
          'credentialSubject',
          'citizenship',
          0,
          'status',
        ]);
        expect(status, 'citizen');

        final canadaStatus = complexCredential.getValueByPath([
          'credentialSubject',
          'citizenship',
          1,
          'status',
        ]);
        expect(canadaStatus, 'permanent_resident');
      });
    });

    group('W3C VC v2.0 support', () {
      test('should create credential from v2.0 data model', () {
        final vcV2 = VcTestData.createW3CCredentialV2(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {
            'id': 'did:example:holder',
            'email': 'alice@example.com',
          },
          id: 'urn:uuid:test-vc-v2',
        );
        expect(vcV2.format, CredentialFormat.ldpVc);

        final email = vcV2.getValueByPath(['credentialSubject', 'email']);
        expect(email, 'alice@example.com');
      });
    });

    group('W3CDigitalCredential edge cases', () {
      test('should handle null values in path traversal', () {
        final credential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'EmailCredential'],
          credentialSubject: {
            'id': 'did:example:alice',
            'email': null,
            'name': 'Alice',
          },
          id: 'vc1',
        );

        final nullEmail = credential.getValueByPath([
          'credentialSubject',
          'email',
        ]);
        expect(nullEmail, isNull);

        final name = credential.getValueByPath(['credentialSubject', 'name']);
        expect(name, 'Alice');
      });

      test('should handle deeply nested null values', () {
        final credential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential'],
          credentialSubject: {
            'id': 'did:example:alice',
            'address': {'street': null, 'city': 'New York', 'country': null},
          },
          id: 'vc1',
        );

        final nullStreet = credential.getValueByPath([
          'credentialSubject',
          'address',
          'street',
        ]);
        expect(nullStreet, isNull);

        final nullCountry = credential.getValueByPath([
          'credentialSubject',
          'address',
          'country',
        ]);
        expect(nullCountry, isNull);

        final city = credential.getValueByPath([
          'credentialSubject',
          'address',
          'city',
        ]);
        expect(city, 'New York');
      });

      test('should handle array with null elements', () {
        final credential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential'],
          credentialSubject: {
            'id': 'did:example:alice',
            'skills': ['Dart', null, 'Flutter', null, 'Testing'],
          },
          id: 'vc1',
        );

        final nullSkill = credential.getValueByPath([
          'credentialSubject',
          'skills',
          1,
        ]);
        expect(nullSkill, isNull);

        final nullSkill2 = credential.getValueByPath([
          'credentialSubject',
          'skills',
          3,
        ]);
        expect(nullSkill2, isNull);

        final dartSkill = credential.getValueByPath([
          'credentialSubject',
          'skills',
          0,
        ]);
        expect(dartSkill, 'Dart');

        final flutterSkill = credential.getValueByPath([
          'credentialSubject',
          'skills',
          2,
        ]);
        expect(flutterSkill, 'Flutter');
      });

      test('should handle empty arrays', () {
        final credential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential'],
          credentialSubject: {
            'id': 'did:example:alice',
            'achievements': <String>[],
          },
          id: 'vc1',
        );

        final achievement = credential.getValueByPath([
          'credentialSubject',
          'achievements',
          0,
        ]);
        expect(achievement, isNull);
      });

      test('should handle out of bounds array access', () {
        final credential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential'],
          credentialSubject: {
            'id': 'did:example:alice',
            'skills': ['Dart', 'Flutter'],
          },
          id: 'vc1',
        );

        final outOfBounds = credential.getValueByPath([
          'credentialSubject',
          'skills',
          5,
        ]);
        expect(outOfBounds, isNull);

        final negativeIndex = credential.getValueByPath([
          'credentialSubject',
          'skills',
          -1,
        ]);
        expect(negativeIndex, isNull);
      });
    });
  });
}
