import '../dcql_credential/dcql_credential.dart';
import '../dcql_credential_query/dcql_credential_query.dart';
import '../dcql_meta/dcql_meta.dart';
import '../digital_credential/digital_credential_interface.dart';
import 'credential_set_match_result.dart';
import 'satisfied_meta.dart';

/// The result of executing a DCQL query against a collection of credentials.
class DcqlQueryResult {
  /// The original query to match against [DigitalCredential]
  final DcqlCredentialQuery query;

  /// Credentials that matched the query requirements, grouped by credential ID.
  final Map<String, Iterable<DigitalCredential>> verifiableCredentials;

  /// Claims that were satisfied for each credential.
  final Map<String, List<Set<String>>> satisfiedClaimsByCredential;

  /// Claims that were not satisfied for each credential.
  final Map<String, List<Set<String>>> unsatisfiedClaimsByCredential;

  /// Credentials from the query that could not be satisfied.
  final Iterable<DcqlCredential> unsatisfiedQueryCredentialSets;

  /// Meta constraints that were satisfied for the query.
  final List<SatisfiedMeta> satisfiedMeta;

  /// Meta constraints that were not satisfied for the query.
  final List<DcqlMeta> unsatisfiedMeta;

  /// Matching results for each credential set in the query,
  /// which provides information about which specific options within each
  /// credential set were matched, enabling wallet implementers to offer
  /// users choices between different valid credential combinations.
  ///
  /// ## Example
  ///
  /// For a query with credential sets like:
  /// ```json
  /// "credential_sets": [{
  ///   "options": [
  ///     ["pid"],
  ///     ["other_pid"],
  ///     ["pid_reduced_cred_1", "pid_reduced_cred_2"]
  ///   ]
  /// }]
  /// ```
  ///
  /// If the wallet has credentials matching both "pid" and "other_pid",
  /// this list will contain a [CredentialSetMatchResult] showing that
  /// multiple options are satisfied, allowing the wallet to present
  /// the user with a choice of which credentials to share.
  final List<CredentialSetMatchResult> matchedCredentialSets;

  /// Creates a [DcqlQueryResult] with the given data.
  DcqlQueryResult({
    required this.query,
    this.verifiableCredentials = const {},
    this.satisfiedClaimsByCredential = const {},
    this.unsatisfiedClaimsByCredential = const {},
    this.unsatisfiedQueryCredentialSets = const [],
    this.satisfiedMeta = const [],
    this.unsatisfiedMeta = const [],
    this.matchedCredentialSets = const [],
  });

  // Helper to evaluate a single credential (including its claim_sets, if any).
  bool _credentialFulfilled(DcqlCredential cred) {
    final hasVc = verifiableCredentials[cred.id]?.isNotEmpty == true;
    if (!hasVc) return false;

    // If no claim_sets are requested, having a VC is enough for this credential.
    final claimSets = cred.claimSets;
    if (claimSets == null || claimSets.isEmpty) return true;

    // If claim_sets are requested, at least one VC (represented by one element in the list)
    // must fully satisfy at least one of the claim_sets options.
    final perVcSatisfiedClaims =
        satisfiedClaimsByCredential[cred.id] ?? const <Set<String>>[];

    // If claim_sets are present but we have no satisfied-claims info, cannot confirm fulfillment here.
    // Fall back to trusting that upstream matching already filtered VCs correctly.
    if (perVcSatisfiedClaims.isEmpty) return true;

    // OR-of-ANDs: exists a VC whose satisfied-claims contains all claims from any requested set.
    return perVcSatisfiedClaims.any(
      (vcClaims) =>
          claimSets.any((requiredSet) => requiredSet.every(vcClaims.contains)),
    );
  }

  /// Returns true if the query was fully satisfied as per specification.
  ///
  /// Checks if all required credentials and claim sets were matched.
  /// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-credential-query).
  bool get fulfilled {
    // Build an index of credentials by id for quick lookup when evaluating credential_sets options.
    final credentialsById = {for (final c in query.credentials) c.id: c};

    // If there are no query-level credential_sets, then all credentials in the query must be fulfilled.
    if (query.credentialSets == null) {
      return query.credentials.every(_credentialFulfilled);
    }

    // each required set must have at least one option (combination of credential ids)
    // where all referenced credentials are fulfilled (including their claim_sets).
    return query.credentialSets!.where((set) => set.required).every(
          (set) => set.options.any(
            (option) => option.every((credentialId) {
              final cred = credentialsById[credentialId];
              if (cred == null) return false;
              return _credentialFulfilled(cred);
            }),
          ),
        );
  }

  /// Returns true is meta constraints are satisfied
  bool get metaFulfilled => (unsatisfiedMeta.isEmpty);

  /// Combines multiple query results into a single result.
  static DcqlQueryResult combine(List<DcqlQueryResult> list) {
    final query = list.first.query;

    if (list.any((result) => result.query != query)) {
      throw Exception('Only results for the same query can be combined');
    }

    final mergedVcs = <String, Iterable<DigitalCredential>>{};
    for (final r in list) {
      mergedVcs.addAll(r.verifiableCredentials);
    }

    final mergedSatisfiedClaims = <String, List<Set<String>>>{};
    for (final r in list) {
      r.satisfiedClaimsByCredential.forEach((credId, perVcSets) {
        final existing = mergedSatisfiedClaims[credId];
        if (existing == null) {
          mergedSatisfiedClaims[credId] = List<Set<String>>.from(perVcSets);
        } else {
          existing.addAll(perVcSets);
        }
      });
    }

    final mergedUnsatisfiedClaims = <String, List<Set<String>>>{};
    for (final r in list) {
      r.unsatisfiedClaimsByCredential.forEach((credId, perVcSets) {
        final existing = mergedUnsatisfiedClaims[credId];
        if (existing == null) {
          mergedUnsatisfiedClaims[credId] = List<Set<String>>.from(perVcSets);
        } else {
          existing.addAll(perVcSets);
        }
      });
    }

    // Merge meta results
    final mergedSatisfiedMeta = <SatisfiedMeta>[];
    final mergedUnsatisfiedMeta = <DcqlMeta>[];

    for (final r in list) {
      mergedSatisfiedMeta.addAll(r.satisfiedMeta);
      mergedUnsatisfiedMeta.addAll(r.unsatisfiedMeta.where(
        (meta) => !mergedSatisfiedMeta.any((sm) => sm.expected == meta),
      ));
    }

    // Merge matched credential sets
    final mergedMatchedCredentialSets = <CredentialSetMatchResult>[];
    for (final r in list) {
      mergedMatchedCredentialSets.addAll(r.matchedCredentialSets);
    }

    return DcqlQueryResult(
      query: query,
      verifiableCredentials: mergedVcs,
      satisfiedClaimsByCredential: mergedSatisfiedClaims,
      unsatisfiedClaimsByCredential: mergedUnsatisfiedClaims,
      unsatisfiedQueryCredentialSets: list.fold(
        [],
        (acc, queryResult) => [
          ...acc,
          ...queryResult.unsatisfiedQueryCredentialSets,
        ],
      ),
      satisfiedMeta: mergedSatisfiedMeta,
      unsatisfiedMeta: mergedUnsatisfiedMeta,
      matchedCredentialSets: mergedMatchedCredentialSets,
    );
  }
}
