/// Represents a matched option within a credential set.
///
/// Each option is a list of credential identifiers that together form
/// a valid combination to satisfy part of the query requirements.
class MatchedOption {
  /// The credential identifiers that make up this option.
  final List<String> credentialIdentifiers;

  /// Whether this option is satisfied (all referenced credentials are available and match).
  final bool matches;

  /// Creates a [MatchedOption] with the given identifiers and match status.
  const MatchedOption({
    required this.credentialIdentifiers,
    required this.matches,
  });

  @override
  String toString() =>
      'MatchedOption(credentialIdentifiers: $credentialIdentifiers, matches: $matches)';
}
