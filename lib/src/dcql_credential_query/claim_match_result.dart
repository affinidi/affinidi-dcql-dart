/// Result of claim matching for a credential.
class ClaimMatchResult {
  /// The set of satisfied claim IDs.
  final Set<String> satisfiedClaims;

  /// The set of unsatisfied claim IDs.
  final Set<String> unsatisfiedClaims;

  /// Whether the credential matches the query.
  final bool credentialMatches;

  /// Creates a new [ClaimMatchResult].
  ClaimMatchResult({
    required this.satisfiedClaims,
    required this.unsatisfiedClaims,
    required this.credentialMatches,
  });
}
