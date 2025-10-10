import 'package:dcql/src/validation_result/validation_result.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationResult', () {
    test('should start with no errors', () {
      final result = ValidationResult();
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('should add single error', () {
      final result = ValidationResult();
      result.addError('Test error');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first, 'Test error');
    });

    test('should add multiple errors', () {
      final result = ValidationResult();
      result.addError('First error');
      result.addError('Second error');
      result.addError('Third error');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(3));
      expect(result.errors, contains('First error'));
      expect(result.errors, contains('Second error'));
      expect(result.errors, contains('Third error'));
    });

    test('should combine with null result', () {
      final result = ValidationResult();
      result.addError('Original error');

      result.combine(null);

      expect(result.errors, hasLength(1));
      expect(result.errors.first, 'Original error');
    });

    test('should combine with empty result', () {
      final result = ValidationResult();
      result.addError('Original error');

      final other = ValidationResult();
      result.combine(other);

      expect(result.errors, hasLength(1));
      expect(result.errors.first, 'Original error');
    });

    test('should combine with result containing errors', () {
      final result = ValidationResult();
      result.addError('Original error');

      final other = ValidationResult();
      other.addError('Other error 1');
      other.addError('Other error 2');

      result.combine(other);

      expect(result.errors, hasLength(3));
      expect(result.errors, contains('Original error'));
      expect(result.errors, contains('Other error 1'));
      expect(result.errors, contains('Other error 2'));
    });

    test('should combine multiple results', () {
      final result = ValidationResult();
      result.addError('First error');

      final other1 = ValidationResult();
      other1.addError('Second error');

      final other2 = ValidationResult();
      other2.addError('Third error');
      other2.addError('Fourth error');

      result.combine(other1);
      result.combine(other2);

      expect(result.errors, hasLength(4));
      expect(result.errors, contains('First error'));
      expect(result.errors, contains('Second error'));
      expect(result.errors, contains('Third error'));
      expect(result.errors, contains('Fourth error'));
    });

    test('should reflect error state correctly', () {
      final result = ValidationResult();
      expect(result.isValid, isTrue);

      result.addError('Error');
      expect(result.isValid, isFalse);
    });
  });
}
