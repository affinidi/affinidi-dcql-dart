import 'package:dcql/src/validation_result/validation_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dcql_claim.g.dart';

/// The DcqlClaim class represents a claim in the claims array of the DcqlCredentialQuery.
/// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#claims_query).
@JsonSerializable()
class DcqlClaim {
  /// Default prefix to be used for auto-generated claim IDs.
  static const String defaultIdPrefix = 'CLAIM_';

  /// Optional identifier for this claim.
  final String? id;

  /// The path to the claim within the credential.
  final List<dynamic> path;

  /// Optional expected values for this claim.
  final List<dynamic>? values;

  /// Creates a DcqlClaim object.
  ///
  /// [id] - REQUIRED if claim_sets is present in the DcqlCredentialQuery; OPTIONAL otherwise.
  /// A string identifying the particular claim.
  /// The value MUST be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.
  /// Within the particular claims array, the same id MUST NOT be present more than once.
  ///
  /// [path] - a required non-empty array representing a claims path pointer that specifies the path to a claim within the DcqlCredential.
  ///
  /// [values] - an options array of strings, integers or boolean values that specifies the expected values of the claim.
  /// If the values property is present, the Wallet SHOULD return the claim only
  /// if the type and value of the claim both match exactly for at least one of the elements in the array.
  DcqlClaim({this.id, required this.path, this.values});

  /// Validates this claim according to DCQL specification.
  ValidationResult validate({
    List<DcqlClaim>? claims,
    List<List<String>>? claimSets,
  }) {
    final result = ValidationResult();

    if (claimSets != null) {
      if (id == null) {
        result.addError('id is required when claim_sets is present');
      }
    }

    if (id != null) {
      if (id!.isEmpty) {
        result.addError('id must be a non-empty string');
      }

      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id!)) {
        result.addError(
          'id must consist of alphanumeric, underscore (_) or hyphen (-) characters',
        );
      }

      if (claims != null) {
        final claimIds = claims.map((claim) => claim.id).toList();
        if (claimIds.where((claimId) => claimId == id).length > 1) {
          result.addError(
            'id must not be present more than once in claims array: claim id: $id',
          );
        }
      }
    }

    if (path.isEmpty) {
      result.addError('path must be a non-empty array');
    }

    if (path.any(
      (element) => (element != null && element is! int && element.isEmpty),
    )) {
      result.addError('path elements must not be empty');
    }

    if (values != null) {
      for (final value in values!) {
        if (value is! String && value is! int && value is! bool) {
          result.addError(
            'values must be an array of strings, integers or boolean values',
          );

          break;
        }
      }
    }

    return result;
  }

  /// Gets the effective ID for this claim.
  /// Returns the explicit ID if provided, otherwise generates a default ID
  /// using the DEFAULT_PREFIX and the claim's position in the query.
  String getEffectiveId(int index) {
    return id ?? '$defaultIdPrefix$index';
  }

  /// Creates a [DcqlClaim] from JSON.
  factory DcqlClaim.fromJson(Map<String, dynamic> json) =>
      _$DcqlClaimFromJson(json);

  /// Converts this [DcqlClaim] to JSON.
  Map<String, dynamic> toJson() => _$DcqlClaimToJson(this);
}
