import 'package:json_annotation/json_annotation.dart';

part 'dcql_credential_set.g.dart';

/// The DcqlCredentialSet class represents a set of credentials that can be used in the DCQL specification.
/// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#credential_sets).
///
/// Credential sets enable complex query logic where multiple credential
/// combinations can satisfy a requirement. This supports OR logic across
/// different credential combinations and allows required vs optional sets.
///
/// Example:
/// ```dart
/// final credentialSet = DcqlCredentialSet(
///   options: [
///     ['passport'],                    // Option 1: Just passport
///     ['license', 'birth_cert']       // Option 2: License AND birth cert
///   ],
///   required: true
/// );
/// ```
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class DcqlCredentialSet {
  /// A non-empty array, where each value in the array is a list of Credential Query identifiers
  /// representing one set of Credentials that satisfies the use case. The value of each element
  /// in the options array is a non-empty array of identifiers which reference elements in credentials.

  final List<List<String>> options;

  /// Whether this credential set is required.
  @JsonKey(defaultValue: true)
  final bool required;

  /// Creates a DcqlCredentialSet object.
  ///
  /// [options] - a non-empty array, where each value in the array is a list of Credential Query identifiers
  /// representing one set of Credentials that satisfies the use case.
  /// The value of each element in the options array is an array of identifiers which reference elements in credentials.
  ///
  /// [required] - a boolean which indicates whether this set of Credentials is required
  /// to satisfy the particular use case at the Verifier.
  /// If omitted, the default value is true.
  DcqlCredentialSet({required this.options, this.required = true});

  /// Creates a [DcqlCredentialSet] from JSON.
  factory DcqlCredentialSet.fromJson(Map<String, dynamic> json) =>
      _$DcqlCredentialSetFromJson(json);

  /// Converts this [DcqlCredentialSet] to JSON.
  Map<String, dynamic> toJson() => _$DcqlCredentialSetToJson(this);
}
