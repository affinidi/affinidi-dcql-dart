// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlCredential _$DcqlCredentialFromJson(Map<String, dynamic> json) =>
    DcqlCredential(
      id: json['id'] as String,
      format: $enumDecode(_$CredentialFormatEnumMap, json['format']),
      multiple: json['multiple'] as bool? ?? false,
      meta: json['meta'] == null
          ? null
          : DcqlMeta.fromJson(json['meta'] as Map<String, dynamic>),
      trustedAuthorities: (json['trusted_authorities'] as List<dynamic>?)
          ?.map((e) => DcqlTrustedAuthority.fromJson(e as Map<String, dynamic>))
          .toList(),
      requireCryptographicHolderBinding:
          json['require_cryptographic_holder_binding'] as bool? ?? true,
      claims: (json['claims'] as List<dynamic>?)
          ?.map((e) => DcqlClaim.fromJson(e as Map<String, dynamic>))
          .toList(),
      claimSets: (json['claim_sets'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
    );

Map<String, dynamic> _$DcqlCredentialToJson(DcqlCredential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'format': _$CredentialFormatEnumMap[instance.format]!,
      'multiple': instance.multiple,
      if (instance.meta?.toJson() case final value?) 'meta': value,
      if (instance.trustedAuthorities?.map((e) => e.toJson()).toList()
          case final value?)
        'trusted_authorities': value,
      if (instance.requireCryptographicHolderBinding case final value?)
        'require_cryptographic_holder_binding': value,
      if (instance.claims?.map((e) => e.toJson()).toList() case final value?)
        'claims': value,
      if (instance.claimSets case final value?) 'claim_sets': value,
    };

const _$CredentialFormatEnumMap = {
  CredentialFormat.jwtVcJson: 'jwt_vc_json',
  CredentialFormat.dcSdJwt: 'dc+sd-jwt',
  CredentialFormat.ldpVc: 'ldp_vc',
  CredentialFormat.msoMdoc: 'mso_mdoc',
  CredentialFormat.acVp: 'ac_vp',
};
