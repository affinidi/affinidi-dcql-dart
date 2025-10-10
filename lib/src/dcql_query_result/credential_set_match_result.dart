import '../dcql_credential_set/dcql_credential_set.dart';
import 'matched_option.dart';

/// Represents the result of matching a single credential set from the query.
///
/// This provides detailed information about which options within the credential
/// set were satisfied, enabling wallet implementers to offer users choices
/// between different valid credential combinations.
class CredentialSetMatchResult {
  /// The original credential set from the query.
  final DcqlCredentialSet credentialSet;

  /// The index of this credential set in the original query.
  final int setIndex;

  /// All options in this credential set with their match status.
  final List<MatchedOption> matchedOptions;

  /// Creates a [CredentialSetMatchResult] with the given data.
  const CredentialSetMatchResult({
    required this.credentialSet,
    required this.setIndex,
    required this.matchedOptions,
  });

  /// Returns true if this credential set is satisfied.
  ///
  /// A credential set is satisfied if:
  /// - It's not required (optional), OR
  /// - At least one of its options is matched
  bool get isSatisfied {
    if (!credentialSet.required) return true;
    return matchedOptions.any((option) => option.matches);
  }

  /// Returns only the options that are satisfied.
  List<MatchedOption> get satisfiedOptions =>
      matchedOptions.where((option) => option.matches).toList();

  /// Returns only the options that are not satisfied.
  List<MatchedOption> get unsatisfiedOptions =>
      matchedOptions.where((option) => !option.matches).toList();

  @override
  String toString() => 'CredentialSetMatchResult('
      'setIndex: $setIndex, '
      'required: ${credentialSet.required}, '
      'satisfied: $isSatisfied, '
      'matchedOptions: $matchedOptions)';
}
