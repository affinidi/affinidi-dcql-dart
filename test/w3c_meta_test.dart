import 'package:test/test.dart';
import 'package:dcql/src/digital_credential/w3c/meta/w3c_meta.dart';

void main() {
  group('W3cMeta', () {
    test('creates with required parameters', () {
      final types = {'VerifiableCredential', 'EmailCredential'};
      final contexts = {'https://www.w3.org/2018/credentials/v1'};

      final meta = W3cMeta(types: types, contexts: contexts);

      expect(meta.types, equals(types));
      expect(meta.contexts, equals(contexts));
    });

    test('should return true when types are not empty', () {
      final meta = W3cMeta(
        types: {'VerifiableCredential'},
        contexts: <String>{},
      );

      expect(meta.isNonEmpty(), isTrue);
    });

    test('should return true when contexts are not empty', () {
      final meta = W3cMeta(
        types: <String>{},
        contexts: {'https://www.w3.org/2018/credentials/v1'},
      );

      expect(meta.isNonEmpty(), isTrue);
    });

    test('should return true when both types and contexts are not empty', () {
      final meta = W3cMeta(
        types: {'VerifiableCredential'},
        contexts: {'https://www.w3.org/2018/credentials/v1'},
      );

      expect(meta.isNonEmpty(), isTrue);
    });

    test('should return false when both types and contexts are empty', () {
      final meta = W3cMeta(types: <String>{}, contexts: <String>{});

      expect(meta.isNonEmpty(), isFalse);
    });

    test('should handle multiple types and contexts', () {
      final types = {
        'VerifiableCredential',
        'EmailCredential',
        'UniversityDegreeCredential',
      };
      final contexts = {
        'https://www.w3.org/2018/credentials/v1',
        'https://www.w3.org/2018/credentials/v2',
      };

      final meta = W3cMeta(types: types, contexts: contexts);

      expect(meta.types, equals(types));
      expect(meta.contexts, equals(contexts));
      expect(meta.isNonEmpty(), isTrue);
    });

    test('should handle empty sets', () {
      final meta = W3cMeta(types: <String>{}, contexts: <String>{});

      expect(meta.types, isEmpty);
      expect(meta.contexts, isEmpty);
      expect(meta.isNonEmpty(), isFalse);
    });
  });
}
