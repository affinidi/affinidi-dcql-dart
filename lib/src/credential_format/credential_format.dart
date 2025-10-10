import 'package:json_annotation/json_annotation.dart';

/// This enum represents the different formats of credentials that can be used in the DCQL specification.
/// * W3C Verifiable Credentials: jwt_vc_json and ldp_vc
/// * AnonCreds: ac_vp
/// * mdocs: mso_mdoc
/// * IETF SD-JWT VC: dc+sd-jwt
///
/// [Credential Format Specific Parameters and Rules](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#format_specific_parameters)
@JsonEnum()
enum CredentialFormat {
  /// W3C Verifiable Credential in JWT format.
  @JsonValue('jwt_vc_json')
  jwtVcJson,

  /// SD-JWT Verifiable Credential.
  ///
  /// Enables selective disclosure of claims, allowing users to share only
  /// specific parts of a credential while keeping other information private.
  @JsonValue('dc+sd-jwt')
  dcSdJwt,

  /// W3C Verifiable Credential in Linked Data Proof format.
  @JsonValue('ldp_vc')
  ldpVc,

  /// ISO 18013-5 mdoc (mobile document) credential.
  @JsonValue('mso_mdoc')
  msoMdoc,

  /// AnonCreds Verifiable Presentation format.
  @JsonValue('ac_vp')
  acVp,
}
