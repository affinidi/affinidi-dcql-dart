import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:dcql/src/validation_result/validation_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dcql_meta.g.dart';

/// DcqlMeta class represents the metadata associated with a credential.
/// The properties of this object are defined per Credential Format.
/// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-credential-query).
/// [Meta for w3c](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-parameters-in-the-meta-para).
/// [Meta for SD JWT](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#sd_jwt_vc_meta_parameter).
/// [Meta for mdoc](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#mdocs_meta_parameter).
@JsonSerializable()
class DcqlMeta {
  /// VCT (Verifiable Credential Type) values for SD-JWT credentials.
  /// Use this to filter SD-JWT credentials by their credential type.
  @JsonKey(name: 'vct_values')
  final List<String>? vctValues;

  /// Document type value for mdoc (mobile document) credentials.
  /// Use this to filter mdoc credentials by their document type.
  @JsonKey(name: 'doctype_value')
  final String? doctypeValue;

  /// Type values for W3C Verifiable Credentials.
  /// Use this to filter W3C credentials by their credential types.
  @JsonKey(name: 'type_values')
  final List<List<String>>? typeValues;

  /// Creates a [DcqlMeta] with the given values.
  DcqlMeta({this.vctValues, this.doctypeValue, this.typeValues});

  /// Creates a [DcqlMeta] for SD-JWT credentials.
  DcqlMeta.forDcSdJwt({required this.vctValues})
    : doctypeValue = null,
      typeValues = null;

  /// Creates a [DcqlMeta] for mdoc credentials.
  DcqlMeta.forMdoc({required this.doctypeValue})
    : vctValues = null,
      typeValues = null;

  /// Creates a [DcqlMeta] for W3C credentials.
  DcqlMeta.forW3C({required this.typeValues})
    : vctValues = null,
      doctypeValue = null;

  /// Creates a [DcqlMeta] from JSON.
  factory DcqlMeta.fromJson(Map<String, dynamic> json) =>
      _$DcqlMetaFromJson(json);

  /// Converts this [DcqlMeta] to JSON.
  Map<String, dynamic> toJson() => _$DcqlMetaToJson(this);

  /// Validates this metadata for the given credential format.
  ValidationResult validate({required CredentialFormat format}) {
    final result = ValidationResult();

    switch (format) {
      case CredentialFormat.dcSdJwt:
        if (vctValues == null || vctValues!.isEmpty) {
          result.addError('vct_values must be provided for dc+sd-jwt format.');
        }
        break;
      case CredentialFormat.ldpVc:
        if (typeValues == null || typeValues!.isEmpty) {
          result.addError('type_values must be provided for w3C format.');
        }
        break;
      case CredentialFormat.msoMdoc:
        throw UnimplementedError(
          'Validation for msoMdoc format is not implemented',
        );
      default:
        break;
    }

    return result;
  }
}
