import 'package:test/test.dart';
import 'package:dcql/src/digital_credential/sd_jwt/meta/sd_jwt.dart';

void main() {
  group('SdJwtMeta', () {
    test('should create with vct parameter', () {
      final meta = SdJwtMeta(vct: 'vct1');

      expect(meta.vct, 'vct1');
    });

    test('should create with different vct values', () {
      final meta1 = SdJwtMeta(vct: 'vct1');
      final meta2 = SdJwtMeta(vct: 'vct2');

      expect(meta1.vct, 'vct1');
      expect(meta2.vct, 'vct2');
    });

    test('should handle empty vct set', () {
      final meta = SdJwtMeta(vct: '');

      expect(meta.vct, isEmpty);
      expect(meta.isNonEmpty(), isFalse);
    });

    test('should return true when vct is not empty', () {
      final meta = SdJwtMeta(vct: 'vct1');
      expect(meta.isNonEmpty(), isTrue);
    });

    test('should return false when vct is empty', () {
      final meta = SdJwtMeta(vct: '');
      expect(meta.isNonEmpty(), isFalse);
    });
  });
}
