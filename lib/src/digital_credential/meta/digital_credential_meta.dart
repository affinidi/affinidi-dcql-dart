/// Base interface for digital credential metadata.
abstract interface class DigitalCredentialMeta {
  /// Returns true if DigitalCredential has meta fields are defined as per verifiable credential format and not empty
  bool isNonEmpty();
}
