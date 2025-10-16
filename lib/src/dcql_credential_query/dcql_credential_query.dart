import 'package:dcql/src/validation_result/validation_result.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../dcql.dart';
import '../dcql_query_result/satisfied_meta.dart';
import '../digital_credential/credential_context.dart';
import '../digital_credential/sd_jwt/meta/sd_jwt.dart';
import '../digital_credential/w3c/meta/w3c_meta.dart';

part 'dcql_credential_query.g.dart';

/// The [DcqlCredentialQuery] class represents a request for a presentation of one or more matching Credentials.
/// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-credential-query).
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class DcqlCredentialQuery {
  /// An array of credential queries that specify the requested credentials.
  final Iterable<DcqlCredential> credentials;

  /// Optional credential sets that define combinations of credentials.
  @JsonKey(name: 'credential_sets')
  final Iterable<DcqlCredentialSet>? credentialSets;

  DcqlCredentialQuery._({required this.credentials, this.credentialSets});

  /// Creates a new [DcqlCredentialQuery].
  factory DcqlCredentialQuery({
    required Iterable<DcqlCredential> credentials,
    Iterable<DcqlCredentialSet>? credentialSets,
  }) {
    if (credentials.isEmpty) {
      throw ArgumentError.value(
          credentials, 'credentials', 'Must contain at least one item.');
    }

    List<ValidationResult> validationResults = [];

    for (final cred in credentials) {
      validationResults.add(cred.validate());
    }

    final hasErrors = validationResults.any((r) => r.errors.isNotEmpty);

    if (hasErrors) {
      throw ArgumentError.value(
          validationResults.fold<String>(
            '',
            (result, r) {
              if (r.errors.isNotEmpty) {
                result += r.errors.map((e) => e.toString()).join(', ');
              }
              return result;
            },
          ).toString(),
          'credentials',
          'Query is invalid:');
    }

    return DcqlCredentialQuery._(
        credentials: credentials, credentialSets: credentialSets);
  }

  /// Creates a [DcqlCredentialQuery] from JSON.
  factory DcqlCredentialQuery.fromJson(Map<String, dynamic> json) =>
      _$DcqlCredentialQueryFromJson(json);

  /// Converts this [DcqlCredentialQuery] to JSON.
  Map<String, dynamic> toJson() => _$DcqlCredentialQueryToJson(this);

  /// Executes the query against the given [verifiableCredentials].
  DcqlQueryResult query(
    Iterable<DigitalCredential> verifiableCredentials,
  ) {
    return _matchVerifiableCredentials(credentials, verifiableCredentials);
  }

  bool _matchedFormat(
      DigitalCredential digitalCredential, DcqlCredential dcqlCredential) {
    return digitalCredential.format == dcqlCredential.format;
  }

  /// Matches verifiable credentials against query credentials.
  DcqlQueryResult _matchVerifiableCredentials(
    Iterable<DcqlCredential> queryCredentials,
    Iterable<DigitalCredential> verifiableCredentials,
  ) {
    var matchedCredentials = <String, Iterable<DigitalCredential>>{};
    var unsatisfiedCredentials = <DcqlCredential>[];
    var satisfiedClaims = <String, List<Set<String>>>{};
    var unsatisfiedClaims = <String, List<Set<String>>>{};
    var satisfiedMeta = <SatisfiedMeta>[];
    var unsatisfiedMeta = <DcqlMeta>[];
    var matchedCredentialSets = <CredentialSetMatchResult>[];

    for (final dcqlCredential in queryCredentials) {
      var credentialMatches = <DigitalCredential>[];
      var satisfiedClaimSetsForCredential = <Set<String>>[];
      var unsatisfiedClaimSetsForCredential = <Set<String>>[];

      for (final vc in verifiableCredentials) {
        // Format must match exactly per spec
        if (!_matchedFormat(vc, dcqlCredential)) {
          continue;
        }

        // Meta constraints matching
        final meta = dcqlCredential.meta;
        if (meta != null) {
          final metaMatch = _matchVerifiableMeta(vc, dcqlCredential);
          if (metaMatch == null) {
            if (!unsatisfiedMeta.contains(meta)) {
              unsatisfiedMeta.add(meta);
            }
            continue;
          }
          satisfiedMeta.add(metaMatch);
        }

        // Claims and claim_sets matching with improved tracking
        final claimMatchResult = _getClaimMatchResult(vc, dcqlCredential);

        // Always track satisfied and unsatisfied claims for this credential
        if (claimMatchResult.satisfiedClaims.isNotEmpty) {
          satisfiedClaimSetsForCredential.add(claimMatchResult.satisfiedClaims);
        }
        if (claimMatchResult.unsatisfiedClaims.isNotEmpty) {
          unsatisfiedClaimSetsForCredential
              .add(claimMatchResult.unsatisfiedClaims);
        }

        if (claimMatchResult.credentialMatches) {
          credentialMatches.add(vc);
        }
      }

      if (credentialMatches.isNotEmpty) {
        matchedCredentials[dcqlCredential.id] = credentialMatches;
      } else {
        unsatisfiedCredentials.add(dcqlCredential);
      }

      // Always track satisfied and unsatisfied claims regardless of credential match
      if (satisfiedClaimSetsForCredential.isNotEmpty) {
        satisfiedClaims[dcqlCredential.id] = satisfiedClaimSetsForCredential;
      }
      if (unsatisfiedClaimSetsForCredential.isNotEmpty) {
        unsatisfiedClaims[dcqlCredential.id] =
            unsatisfiedClaimSetsForCredential;
      }
    }

    if (credentialSets != null) {
      int setIndex = 0;
      for (final credentialSet in credentialSets!) {
        final matchedOptions = <MatchedOption>[];

        for (final option in credentialSet.options) {
          final allCredentialsSatisfied = option.every(
            (credentialId) => matchedCredentials.containsKey(credentialId),
          );

          matchedOptions.add(MatchedOption(
            credentialIdentifiers: option,
            matches: allCredentialsSatisfied,
          ));
        }

        matchedCredentialSets.add(CredentialSetMatchResult(
          credentialSet: credentialSet,
          setIndex: setIndex,
          matchedOptions: matchedOptions,
        ));

        setIndex++;
      }
    }

    return DcqlQueryResult(
      query: this,
      verifiableCredentials: matchedCredentials,
      satisfiedClaimsByCredential: satisfiedClaims,
      unsatisfiedClaimsByCredential: unsatisfiedClaims,
      unsatisfiedQueryCredentialSets: unsatisfiedCredentials,
      satisfiedMeta: satisfiedMeta,
      unsatisfiedMeta: unsatisfiedMeta,
      matchedCredentialSets: matchedCredentialSets,
    );
  }

  /// Gets the matching result for claims in a digital credential.
  /// Returns claim IDs with default IDs when necessary, and tracks both satisfied and unsatisfied claims.
  ClaimMatchResult _getClaimMatchResult(
    DigitalCredential digitalCredential,
    DcqlCredential dcqlCredential,
  ) {
    if (dcqlCredential.claims == null) {
      return ClaimMatchResult(
        satisfiedClaims: <String>{},
        unsatisfiedClaims: <String>{},
        credentialMatches: true,
      );
    }

    final satisfiedClaims = <String>{};
    final unsatisfiedClaims = <String>{};
    var matchedClaimsCount = 0;

    // First check which individual claims match and generate default IDs as needed
    for (int i = 0; i < dcqlCredential.claims!.length; i++) {
      final claim = dcqlCredential.claims![i];
      final effectiveId = claim.getEffectiveId(i);

      if (_matchesClaim(digitalCredential, claim)) {
        matchedClaimsCount++;
        satisfiedClaims.add(effectiveId);
      } else {
        unsatisfiedClaims.add(effectiveId);
      }
    }

    // If no claim_sets specified, all claims must match
    if (dcqlCredential.claimSets == null) {
      final credentialMatches =
          matchedClaimsCount == dcqlCredential.claims!.length;
      return ClaimMatchResult(
        satisfiedClaims: satisfiedClaims,
        unsatisfiedClaims: unsatisfiedClaims,
        credentialMatches: credentialMatches,
      );
    }

    // Check if any claim_set is fully satisfied
    final anySatisfied = dcqlCredential.claimSets!.any((set) {
      return set.every((claimId) => satisfiedClaims.contains(claimId));
    });

    return ClaimMatchResult(
      satisfiedClaims: satisfiedClaims,
      unsatisfiedClaims: unsatisfiedClaims,
      credentialMatches: anySatisfied,
    );
  }

  /// Checks if a specific claim matches the expected values.
  bool _matchesClaim(DigitalCredential digitalCredential, DcqlClaim dcqlClaim) {
    final actual = digitalCredential.getValueByPath(dcqlClaim.path);

    // If the value does not exist in the credential, claim does not match.
    if (actual == null) {
      return false;
    }

    // If no explicit values constraint specified, the presence of the value suffices.
    final expectedValues = dcqlClaim.values;

    if (expectedValues == null || expectedValues.isEmpty) {
      return true;
    }

    // Handle array values
    if (actual is List) {
      return expectedValues.any((v) => actual.contains(v));
    }

    return expectedValues.any((v) => v == actual);
  }

  /// Matches meta constraints and returns the matched values if successful.
  SatisfiedMeta? _matchVerifiableMeta(
    DigitalCredential digitalCredential,
    DcqlCredential dcqlCredential,
  ) {
    final meta = dcqlCredential.meta;
    final credentialFormat = dcqlCredential.format;
    // If no meta constraints are defined, treat as match
    if (meta == null) return null;

    switch (credentialFormat) {
      case CredentialFormat.ldpVc:
        return _matchW3CMeta(
            digitalCredential: digitalCredential,
            dcqlCredential: dcqlCredential);
      case CredentialFormat.dcSdJwt:
        return _matchSdJwtMeta(
          digitalCredential: digitalCredential,
          dcqlCredential: dcqlCredential,
        );
      case CredentialFormat.msoMdoc:
      case CredentialFormat.jwtVcJson:
      case CredentialFormat.acVp:
        // Not modeled in DcqlMeta yet. No meta filtering.
        throw UnimplementedError(
            'Meta matching not implemented for ${credentialFormat.name}');
    }
  }

  /// Matches W3C credential metadata against query requirements.
  SatisfiedMeta? _matchW3CMeta({
    required DigitalCredential digitalCredential,
    required DcqlCredential dcqlCredential,
  }) {
    final actualMeta = digitalCredential.meta as W3cMeta;
    final requestedTypeValues = dcqlCredential.meta!.typeValues;

    // Per spec, type_values is required for W3C meta, but if it's absent/empty in input,
    // treat as no additional filtering to be resilient.
    if (requestedTypeValues == null || requestedTypeValues.isEmpty) {
      return SatisfiedMeta(
        expected: dcqlCredential.meta!,
        actual: actualMeta.types.toList(),
      );
    }

    // Expand actual VC types into fully expanded IRIs (heuristic per spec guidance)
    final actualExpandedTypes = _expandW3CContextLd(
        types: actualMeta.types, contexts: actualMeta.contexts);

    // Model currently supports a flat list of type values. Treat each as an OR option.
    for (final typeValueArray in requestedTypeValues) {
      if (typeValueArray.isEmpty) continue;

      for (final type in typeValueArray) {
        if (actualExpandedTypes.contains(type)) {
          return SatisfiedMeta(
            expected: dcqlCredential.meta!,
            actual: actualMeta.types.toList(),
          );
        }
      }
    }
    return null;
  }

  /// Matched SD-JWT metadata against query requirements.
  SatisfiedMeta? _matchSdJwtMeta({
    required DigitalCredential digitalCredential,
    required DcqlCredential dcqlCredential,
  }) {
    final actualMeta = digitalCredential.meta as SdJwtMeta;
    final requestedVct = dcqlCredential.meta!.vctValues;
    // Per spec, vct_values is required, but if empty here, treat as no-op
    if (requestedVct == null || requestedVct.isEmpty) {
      return SatisfiedMeta(
        expected: dcqlCredential.meta!,
        actual: [actualMeta.vct ?? ''],
      );
    }

    final actualVct = actualMeta.vct;
    // If credential has no vct, but it is requested then it is a mismatch
    if (actualVct == null) {
      return null;
    }

    // Match if any of the actual vct types equals any requested value
    final requestedSet = requestedVct.toSet();
    final matches = requestedSet.intersection({actualMeta.vct});

    if (matches.isNotEmpty) {
      return SatisfiedMeta(
        expected: dcqlCredential.meta!,
        actual: [actualMeta.vct ?? ''],
      );
    }
    return null;
  }

  /// Expand W3C VC type names to fully expanded IRIs as per spec guidance.
  ///
  /// Inputs:
  /// - types: the VC's `type` array values as strings.
  /// - contexts: the VC's `@context` values.
  /// Output: a set including original types and likely expanded IRIs derived
  /// from common context bases. If a type is already an absolute IRI (contains
  /// ':' or starts with http/https), it is included as-is.
  Set<String> _expandW3CContextLd({
    required Set<String> types,
    required Set<String> contexts,
  }) {
    final result = <String>{};

    // Always include raw types (relative IRIs remain unchanged per spec if not defined in any @context)
    result.addAll(types);

    // Build list of candidate bases derived from contexts
    final bases = <String>{};
    for (final ctx in contexts) {
      if (ctx.isEmpty) continue;
      // Add the context itself as a base (with '#')
      bases.add(ctx);

      // If context ends with '/v<digits>', also add the parent path as base
      final versionSuffix = RegExp(r"/v\d+$");
      if (versionSuffix.hasMatch(ctx)) {
        final base = ctx.replaceFirst(versionSuffix, '');
        bases.add(base);
      }
    }

    // Common well-known bases to account for JSON-LD contexts
    // credentials v1
    if (contexts.contains(CredentialContext.v1.url)) {
      bases.add(CredentialContext.v1base.url);
    }
    // credentials v2
    if (contexts.contains(CredentialContext.v2.url)) {
      bases.add(CredentialContext.v2.url);
    }

    for (final t in types) {
      // Skip if looks like absolute IRI already
      final looksIri = t.contains(':') || t.startsWith('https://');
      if (looksIri) {
        result.add(t);
        continue;
      }

      for (final base in bases) {
        // Prefer hash separator by default per examples in the spec
        result.add('$base#$t');
      }
    }
    return result;
  }
}
