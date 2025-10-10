import '../../meta/digital_credential_meta.dart';

/// Metadata for W3C credentials containing type and context information.
class W3cMeta implements DigitalCredentialMeta {
  /// The credential types (e.g., ["VerifiableCredential", "Email"]).
  final Set<String> types;

  /// The JSON-LD context URLs (e.g., ["https://www.w3.org/2018/credentials/v1"]).
  final Set<String> contexts;

  /// Creates a [W3cMeta] with the given types and contexts.
  W3cMeta({required this.types, required this.contexts});

  @override
  bool isNonEmpty() => types.isNotEmpty || contexts.isNotEmpty;
}
