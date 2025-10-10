import '../credential_format/credential_format.dart';
import 'meta/digital_credential_meta.dart';

/// Base interface for all digital credentials supported by this library.
abstract interface class DigitalCredential {
  /// The credential's format (e.g., W3C LDP VC, SD-JWT).
  CredentialFormat get format;

  ///
  /// Returns the value at the specified path within the digital credential.
  /// If the path does not exist, it returns null.
  ///
  dynamic getValueByPath(List<dynamic> path);

  /// Format-specific metadata for this credential.
  DigitalCredentialMeta get meta;
}
