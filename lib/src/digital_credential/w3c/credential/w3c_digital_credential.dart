import 'package:selective_disclosure_jwt/selective_disclosure_jwt.dart';
import 'package:ssi/ssi.dart';

import '../../../credential_format/credential_format.dart';
import '../../digital_credential_interface.dart';
import '../meta/w3c_meta.dart';

/// A digital credential implementation for W3C Verifiable Credentials.
class W3CDigitalCredential implements DigitalCredential {
  final VerifiableCredential _vc;

  @override
  final CredentialFormat format = CredentialFormat.ldpVc;

  /// Creates a [W3CDigitalCredential] from W3C VC v1.0 JSON data.
  W3CDigitalCredential.fromLdVcDataModelV1(Map<String, dynamic> json)
      : _vc = VcDataModelV1.fromJson(json);

  /// Creates a [W3CDigitalCredential] from W3C VC v2.0 JSON data.
  W3CDigitalCredential.fromLdVcDataModelV2(Map<String, dynamic> json)
      : _vc = VcDataModelV2.fromJson(json);

  /// Creates a [W3CDigitalCredential] from a [SdJwt].
  W3CDigitalCredential.fromSdJwt(SdJwt sdJwt)
      : _vc = SdJwtDataModelV2.fromSdJwt(sdJwt);

  @override
  dynamic getValueByPath(List<dynamic> path) {
    return _getValueByPath(_vc.toJson(), path);
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
  W3cMeta get meta {
    // Extract context data from JsonLdContext object
    // The context property can be either a List of strings or a single String
    // Note: Embedded context objects (Maps) are ignored for query complexity
    // and only URI strings are extracted
    final contextData = _vc.context.context;

    Set<String> contextSet;
    if (contextData is List) {
      contextSet = contextData.whereType<String>().toSet();
    } else if (contextData is String) {
      contextSet = {contextData};
    } else {
      contextSet = <String>{};
    }

    return W3cMeta(types: _vc.type, contexts: contextSet);
  }
}
