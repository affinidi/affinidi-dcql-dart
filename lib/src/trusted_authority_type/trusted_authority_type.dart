import 'package:json_annotation/json_annotation.dart';

/// Types of trusted authority sources supported in DCQL.
@JsonEnum()
enum TrustedAuthorityType {
  /// Authority Key Identifier
  aki,

  /// ETSI Trusted List
  @JsonValue('etsi_tl')
  etsiTl,

  /// OpenID Federation
  @JsonValue('openid_federation')
  openidFederation,
}
