import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:test/test.dart';

void main() {
  group('DcqlClaim validation', () {
    group('id validation', () {
      test('should pass with null id when no claim sets', () {
        final claim = DcqlClaim(path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail when id is null but claim sets present', () {
        final claim = DcqlClaim(path: ['name']);
        final result = claim.validate(claimSets: [
          ['name']
        ]);
        expect(result.isValid, isFalse);
        expect(result.errors,
            contains('id is required when claim_sets is present'));
      });

      test('should fail when id is empty string', () {
        final claim = DcqlClaim(id: '', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('id must be a non-empty string'));
      });

      test('should pass with valid alphanumeric id', () {
        final claim = DcqlClaim(id: 'validId123', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid id containing underscores', () {
        final claim = DcqlClaim(id: 'valid_id_123', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid id containing hyphens', () {
        final claim = DcqlClaim(id: 'valid-id-123', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with mixed valid characters', () {
        final claim = DcqlClaim(id: 'Valid_ID-123', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with invalid characters - spaces', () {
        final claim = DcqlClaim(id: 'invalid id', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'id must consist of alphanumeric, underscore (_) or hyphen (-) characters'));
      });

      test('should fail with invalid characters - special symbols', () {
        final claim = DcqlClaim(id: 'invalid@id!', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'id must consist of alphanumeric, underscore (_) or hyphen (-) characters'));
      });

      test('should fail with invalid characters - dots', () {
        final claim = DcqlClaim(id: 'invalid.id', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'id must consist of alphanumeric, underscore (_) or hyphen (-) characters'));
      });
    });

    group('id duplication validation', () {
      test('should pass when no duplicate ids in claims array', () {
        final claim1 = DcqlClaim(id: 'name', path: ['name']);
        final claim2 = DcqlClaim(id: 'age', path: ['age']);
        final claim3 = DcqlClaim(id: 'email', path: ['email']);

        final result = claim1.validate(claims: [claim1, claim2, claim3]);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail when duplicate ids exist in claims array', () {
        final claim1 = DcqlClaim(id: 'duplicate', path: ['name']);
        final claim2 = DcqlClaim(id: 'duplicate', path: ['surname']);
        final claim3 = DcqlClaim(id: 'unique', path: ['age']);

        final result = claim1.validate(claims: [claim1, claim2, claim3]);
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'id must not be present more than once in claims array: claim id: duplicate'));
      });

      test('should fail when multiple duplicates of same id', () {
        final claim1 = DcqlClaim(id: 'triple', path: ['name']);
        final claim2 = DcqlClaim(id: 'triple', path: ['surname']);
        final claim3 = DcqlClaim(id: 'triple', path: ['nickname']);

        final result = claim1.validate(claims: [claim1, claim2, claim3]);
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'id must not be present more than once in claims array: claim id: triple'));
      });

      test('should pass when only one claim has a specific id', () {
        final claim1 = DcqlClaim(id: 'unique', path: ['name']);
        final claim2 = DcqlClaim(id: null, path: ['surname']);
        final claim3 = DcqlClaim(id: 'other', path: ['age']);

        final result = claim1.validate(claims: [claim1, claim2, claim3]);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should handle null ids in duplication check', () {
        final claim1 = DcqlClaim(id: null, path: ['name']);
        final claim2 = DcqlClaim(id: null, path: ['surname']);
        final claim3 = DcqlClaim(id: 'unique', path: ['age']);

        final result = claim1.validate(claims: [claim1, claim2, claim3]);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });
    });

    group('path validation', () {
      test('should pass with valid single element path', () {
        final claim = DcqlClaim(id: 'test', path: ['name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid multi-element path', () {
        final claim =
            DcqlClaim(id: 'test', path: ['credentialSubject', 'name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with mixed path element types', () {
        final claim =
            DcqlClaim(id: 'test', path: ['credentialSubject', 0, 'name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with empty path array', () {
        final claim = DcqlClaim(id: 'test', path: []);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('path must be a non-empty array'));
      });

      test('should fail with empty string in path', () {
        final claim = DcqlClaim(id: 'test', path: ['credentialSubject', '']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('path elements must not be empty'));
      });

      test('should fail with multiple empty strings in path', () {
        final claim = DcqlClaim(id: 'test', path: ['', 'name', '']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('path elements must not be empty'));
      });

      test('should pass with null elements in path (allowed)', () {
        final claim =
            DcqlClaim(id: 'test', path: ['credentialSubject', null, 'name']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });
    });

    group('values validation', () {
      test('should pass with null values', () {
        final claim = DcqlClaim(id: 'test', path: ['name'], values: null);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with empty values array', () {
        final claim = DcqlClaim(id: 'test', path: ['name'], values: []);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid string values', () {
        final claim =
            DcqlClaim(id: 'test', path: ['name'], values: ['Alice', 'Bob']);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid integer values', () {
        final claim =
            DcqlClaim(id: 'test', path: ['age'], values: [25, 30, 35]);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with valid boolean values', () {
        final claim =
            DcqlClaim(id: 'test', path: ['active'], values: [true, false]);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should pass with mixed valid types', () {
        final claim =
            DcqlClaim(id: 'test', path: ['mixed'], values: ['Alice', 30, true]);
        final result = claim.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should fail with double values', () {
        final claim =
            DcqlClaim(id: 'test', path: ['score'], values: [3.14, 2.7]);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should fail with object values', () {
        final claim = DcqlClaim(id: 'test', path: [
          'object'
        ], values: [
          {'key': 'value'}
        ]);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should fail with array values', () {
        final claim = DcqlClaim(id: 'test', path: [
          'array'
        ], values: [
          ['item1', 'item2']
        ]);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should fail with mixed invalid and valid types', () {
        final claim =
            DcqlClaim(id: 'test', path: ['mixed'], values: ['Alice', 30, 3.14]);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should fail with null values in array', () {
        final claim = DcqlClaim(
            id: 'test', path: ['nullable'], values: ['Alice', null, 'Bob']);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should stop at first invalid value type', () {
        final claim = DcqlClaim(id: 'test', path: [
          'multi'
        ], values: [
          3.14,
          ['array'],
          {'key': 'value'}
        ]);
        final result = claim.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, hasLength(1));
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });
    });

    group('combined validation scenarios', () {
      test('should validate all constraints when claim sets provided', () {
        final claim = DcqlClaim(id: null, path: [], values: [3.14]);
        final result = claim.validate(claimSets: [
          ['test']
        ]);
        expect(result.isValid, isFalse);
        expect(result.errors, hasLength(3));
        expect(result.errors,
            contains('id is required when claim_sets is present'));
        expect(result.errors, contains('path must be a non-empty array'));
        expect(
            result.errors,
            contains(
                'values must be an array of strings, integers or boolean values'));
      });

      test('should pass validation when all constraints satisfied', () {
        final claim1 = DcqlClaim(
            id: 'name',
            path: ['credentialSubject', 'name'],
            values: ['Alice', 'Bob']);
        final claim2 = DcqlClaim(
            id: 'age', path: ['credentialSubject', 'age'], values: [25, 30]);

        final result = claim1.validate(claims: [
          claim1,
          claim2
        ], claimSets: [
          ['name', 'age']
        ]);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });
    });
  });
}
