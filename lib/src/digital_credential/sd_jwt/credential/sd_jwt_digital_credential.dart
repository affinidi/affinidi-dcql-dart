import 'package:selective_disclosure_jwt/selective_disclosure_jwt.dart';

import '../../../credential_format/credential_format.dart';
import '../../digital_credential_interface.dart';
import '../meta/sd_jwt.dart';

/// A digital credential implementation for SD-JWT format.
///
/// SD-JWT allows selective disclosure of claims, meaning you can share only
/// specific parts of a credential while keeping other information private.
class SdJwtDigitalCredential implements DigitalCredential {
  final Map<String, dynamic> _claims;

  @override
  final CredentialFormat format = CredentialFormat.dcSdJwt;

  /// Creates an [SdJwtDigitalCredential] from an [SdJwt].
  ///
  /// Use this when you have a raw SD-JWT string that needs to be parsed.
  /// This is the primary way to create SD-JWT credentials.

  SdJwtDigitalCredential.fromSdJwt({
    required String sdJwtToken,
  }) : _claims =
            SdJwtHandlerV1().unverifiedDecode(sdJwtToken: sdJwtToken).claims;

  @override
  dynamic getValueByPath(List<dynamic> path) {
    return _getValueByPath(_claims, path);
  }

  dynamic _getValueByPath(dynamic current, List<dynamic> path) {
    if (path.isEmpty) return current;
    if (current == null) return null;

    final head = path.first;
    final remaining = path.sublist(1);

    if (current is Map<String, dynamic>) {
      if (!current.containsKey(head)) return null;
      return _getValueByPath(current[head], remaining);
    }

    if (current is List) {
      if (head == null) {
        // For wildcard/null, return all elements of the array
        return current
            .map((item) => _getValueByPath(item, remaining))
            .where((result) => result != null)
            .toList();
      } else if (head is int) {
        // For integer index, access specific element
        if (head >= 0 && head < current.length) {
          return _getValueByPath(current[head], remaining);
        }
        return null;
      }
    }

    return null;
  }

  @override
  SdJwtMeta get meta => SdJwtMeta(vct: _claims['vct']);
}
