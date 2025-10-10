import 'package:dcql/src/trusted_authority_type/trusted_authority_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dcql_trusted_authority.g.dart';

/// Defines which issuers or trust frameworks are acceptable for credential verification.
///
/// It ensures only credentials from trusted sources are accepted
@JsonSerializable()
class DcqlTrustedAuthority {
  /// The type of trusted authority information.
  final TrustedAuthorityType type;

  /// Values that identify the trusted authority.
  final List<String> values;

  /// Creates a DcqlTrustedAuthority object.
  ///
  /// [type] - a string uniquely identifying the type of information about the issuer trust framework.
  ///
  /// [values] - an array of strings, where each string (value) contains information
  /// specific to the used Trusted Authorities Query type
  /// that allows to identify an issuer, trust framework, or a federation that an issuer belongs to.
  DcqlTrustedAuthority({required this.type, required this.values});

  /// Creates a [DcqlTrustedAuthority] from JSON.
  factory DcqlTrustedAuthority.fromJson(Map<String, dynamic> json) =>
      _$DcqlTrustedAuthorityFromJson(json);

  /// Converts this [DcqlTrustedAuthority] to JSON.
  Map<String, dynamic> toJson() => _$DcqlTrustedAuthorityToJson(this);
}
