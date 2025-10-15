import 'package:dcql/src/dcql_query_result/satisfied_meta.dart';
import 'package:test/test.dart';
import 'helpers/meta_test_utils.dart';

void main() {
  group('SatisfiedMeta', () {
    group('W3C meta creation', () {
      test('should create instance with W3C meta correctly', () {
        final expectedMeta = createW3cMeta([
          ['Email'],
        ]);
        final actualTypes = ['VerifiableCredential', 'Email'];

        final satisfiedMeta = SatisfiedMeta(
          expected: expectedMeta,
          actual: actualTypes,
        );

        expect(satisfiedMeta.expected, equals(expectedMeta));
        expect(satisfiedMeta.actual, equals(actualTypes));
        expect(
          satisfiedMeta.expected.typeValues,
          equals([
            ['Email'],
          ]),
        );
      });
    });

    group('SD-JWT meta creation', () {
      test('should create instance with SD-JWT meta correctly', () {
        final expectedMeta = createSdJwtMeta(['EmailCredential']);
        final actualTypes = ['EmailCredential', 'BasicCredential'];

        final satisfiedMeta = SatisfiedMeta(
          expected: expectedMeta,
          actual: actualTypes,
        );

        expect(satisfiedMeta.expected, equals(expectedMeta));
        expect(satisfiedMeta.actual, equals(actualTypes));
        expect(satisfiedMeta.expected.vctValues, equals(['EmailCredential']));
      });
    });

    group('mdoc meta creation', () {
      test('should create instance with mdoc meta correctly', () {
        final expectedMeta = createMdocMeta('eu.europa.ec.eudiw.pid.1');
        final actualTypes = ['eu.europa.ec.eudiw.pid.1'];

        final satisfiedMeta = SatisfiedMeta(
          expected: expectedMeta,
          actual: actualTypes,
        );

        expect(satisfiedMeta.expected, equals(expectedMeta));
        expect(satisfiedMeta.actual, equals(actualTypes));
        expect(
          satisfiedMeta.expected.doctypeValue,
          equals('eu.europa.ec.eudiw.pid.1'),
        );
      });
    });

    group('edge cases', () {
      test('should handle empty actual values', () {
        final expectedMeta = createW3cMeta([]);
        final actualTypes = <String>[];

        final satisfiedMeta = SatisfiedMeta(
          expected: expectedMeta,
          actual: actualTypes,
        );

        expect(satisfiedMeta.actual, isEmpty);
        expect(satisfiedMeta.expected.typeValues, isEmpty);
      });
    });
  });
}
