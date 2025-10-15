/// Known JSON-LD context URLs for W3C Verifiable Credentials.
enum CredentialContext {
  /// Base credentials context
  v1base('https://www.w3.org/2018/credentials'),

  /// Credentials v1 context.
  v1('https://www.w3.org/2018/credentials/v1'),

  /// Credentials v2 context.
  v2('https://www.w3.org/ns/credentials/v2');

  /// The full context URL.
  final String url;

  const CredentialContext(this.url);
}
