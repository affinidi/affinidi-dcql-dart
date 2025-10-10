import '../../meta/digital_credential_meta.dart';

/// Metadata for SD-JWT credentials containing Verifiable Credential Type information.
class SdJwtMeta implements DigitalCredentialMeta {
  /// The Verifiable Credential Type value for this credential.
  final String? vct;

  /// Creates an [SdJwtMeta] with the given Verifiable Credential Type values.
  SdJwtMeta({this.vct});

  @override
  bool isNonEmpty() => vct?.isNotEmpty ?? false;
}
