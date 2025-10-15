import 'package:dcql/src/dcql_meta/dcql_meta.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:test/test.dart';

void main() {
  group('DcqlMeta', () {
    test('should create with all parameters', () {
      final meta = DcqlMeta(
        vctValues: ['EmailCredential'],
        doctypeValue: 'org.iso.18013.5.1.mDL',
        typeValues: [
          ['PersonCredential'],
          ['EmailCredential'],
        ],
      );

      expect(meta.vctValues, ['EmailCredential']);
      expect(meta.doctypeValue, 'org.iso.18013.5.1.mDL');
      expect(meta.typeValues, hasLength(2));
    });

    test('should create for SD-JWT credentials', () {
      final meta = DcqlMeta.forDcSdJwt(
        vctValues: ['EmailCredential', 'PersonCredential'],
      );

      expect(meta.vctValues, ['EmailCredential', 'PersonCredential']);
      expect(meta.doctypeValue, isNull);
      expect(meta.typeValues, isNull);
    });

    test('should create for mdoc credentials', () {
      final meta = DcqlMeta.forMdoc(doctypeValue: 'org.iso.18013.5.1.mDL');

      expect(meta.doctypeValue, 'org.iso.18013.5.1.mDL');
      expect(meta.vctValues, isNull);
      expect(meta.typeValues, isNull);
    });

    test('should create for W3C credentials', () {
      final meta = DcqlMeta.forW3C(
        typeValues: [
          ['PersonCredential'],
          ['EmailCredential'],
        ],
      );

      expect(meta.typeValues, hasLength(2));
      expect(meta.typeValues![0], ['PersonCredential']);
      expect(meta.typeValues![1], ['EmailCredential']);
      expect(meta.vctValues, isNull);
      expect(meta.doctypeValue, isNull);
    });

    group('validation', () {
      test('should validate dcSdJwt format requires vct_values', () {
        final meta = DcqlMeta();
        final result = meta.validate(format: CredentialFormat.dcSdJwt);

        expect(result.isValid, isFalse);
        expect(
          result.errors,
          contains('vct_values must be provided for dc+sd-jwt format.'),
        );
      });

      test('should validate dcSdJwt format with empty vct_values', () {
        final meta = DcqlMeta(vctValues: []);
        final result = meta.validate(format: CredentialFormat.dcSdJwt);

        expect(result.isValid, isFalse);
        expect(
          result.errors,
          contains('vct_values must be provided for dc+sd-jwt format.'),
        );
      });

      test('should validate dcSdJwt format with valid vct_values', () {
        final meta = DcqlMeta.forDcSdJwt(vctValues: ['EmailCredential']);
        final result = meta.validate(format: CredentialFormat.dcSdJwt);

        expect(result.isValid, isTrue);
      });

      test('should validate ldpVc format requires type_values', () {
        final meta = DcqlMeta();
        final result = meta.validate(format: CredentialFormat.ldpVc);

        expect(result.isValid, isFalse);
        expect(
          result.errors,
          contains('type_values must be provided for w3C format.'),
        );
      });

      test('should validate ldpVc format with empty type_values', () {
        final meta = DcqlMeta(typeValues: []);
        final result = meta.validate(format: CredentialFormat.ldpVc);

        expect(result.isValid, isFalse);
        expect(
          result.errors,
          contains('type_values must be provided for w3C format.'),
        );
      });

      test('should validate ldpVc format with valid type_values', () {
        final meta = DcqlMeta.forW3C(
          typeValues: [
            ['PersonCredential'],
          ],
        );
        final result = meta.validate(format: CredentialFormat.ldpVc);

        expect(result.isValid, isTrue);
      });

      test('should throw UnimplementedError for msoMdoc format', () {
        final meta = DcqlMeta();

        expect(
          () => meta.validate(format: CredentialFormat.msoMdoc),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should validate jwtVcJson format without errors', () {
        final meta = DcqlMeta();
        final result = meta.validate(format: CredentialFormat.jwtVcJson);

        expect(result.isValid, isTrue);
      });

      test('should validate acVp format without errors', () {
        final meta = DcqlMeta();
        final result = meta.validate(format: CredentialFormat.acVp);

        expect(result.isValid, isTrue);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final meta = DcqlMeta(
          vctValues: ['EmailCredential'],
          doctypeValue: 'org.iso.18013.5.1.mDL',
          typeValues: [
            ['PersonCredential'],
          ],
        );

        final json = meta.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['vct_values'], ['EmailCredential']);
        expect(json['doctype_value'], 'org.iso.18013.5.1.mDL');
        expect(json['type_values'], [
          ['PersonCredential'],
        ]);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'vct_values': ['EmailCredential'],
          'doctype_value': 'org.iso.18013.5.1.mDL',
          'type_values': [
            ['PersonCredential'],
          ],
        };

        final meta = DcqlMeta.fromJson(json);

        expect(meta.vctValues, ['EmailCredential']);
        expect(meta.doctypeValue, 'org.iso.18013.5.1.mDL');
        expect(meta.typeValues, [
          ['PersonCredential'],
        ]);
      });

      test('should preserve data in round-trip serialization', () {
        final original = DcqlMeta.forW3C(
          typeValues: [
            ['PersonCredential'],
            ['EmailCredential'],
          ],
        );

        final json = original.toJson();
        final deserialized = DcqlMeta.fromJson(json);

        expect(deserialized.typeValues, original.typeValues);
        expect(deserialized.vctValues, original.vctValues);
        expect(deserialized.doctypeValue, original.doctypeValue);
      });

      test('should handle null values in JSON', () {
        final json = {
          'vct_values': null,
          'doctype_value': null,
          'type_values': null,
        };

        final meta = DcqlMeta.fromJson(json);

        expect(meta.vctValues, isNull);
        expect(meta.doctypeValue, isNull);
        expect(meta.typeValues, isNull);
      });
    });

    group('edge cases', () {
      test('should handle empty vct_values list', () {
        final meta = DcqlMeta(vctValues: []);
        expect(meta.vctValues, isEmpty);
      });

      test('should handle empty type_values list', () {
        final meta = DcqlMeta(typeValues: []);
        expect(meta.typeValues, isEmpty);
      });

      test('should handle empty type_values sublists', () {
        final meta = DcqlMeta(
          typeValues: [
            [],
            ['PersonCredential'],
          ],
        );
        expect(meta.typeValues, hasLength(2));
        expect(meta.typeValues![0], isEmpty);
        expect(meta.typeValues![1], ['PersonCredential']);
      });

      test('should handle multiple vct_values', () {
        final meta = DcqlMeta.forDcSdJwt(
          vctValues: ['EmailCredential', 'PersonCredential', 'DrivingLicense'],
        );
        expect(meta.vctValues, hasLength(3));
        expect(meta.vctValues, contains('EmailCredential'));
        expect(meta.vctValues, contains('PersonCredential'));
        expect(meta.vctValues, contains('DrivingLicense'));
      });

      test('should handle complex type_values structure', () {
        final meta = DcqlMeta.forW3C(
          typeValues: [
            ['VerifiableCredential', 'PersonCredential'],
            ['VerifiableCredential', 'EmailCredential'],
            ['DrivingLicense'],
          ],
        );
        expect(meta.typeValues, hasLength(3));
        expect(meta.typeValues![0], hasLength(2));
        expect(meta.typeValues![1], hasLength(2));
        expect(meta.typeValues![2], hasLength(1));
      });
    });
  });
}
