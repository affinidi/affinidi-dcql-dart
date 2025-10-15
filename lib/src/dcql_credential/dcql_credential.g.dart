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
      'meta': ?instance.meta,
      'trusted_authorities': ?instance.trustedAuthorities,
      'require_cryptographic_holder_binding':
          ?instance.requireCryptographicHolderBinding,
      'claims': ?instance.claims,
      'claim_sets': ?instance.claimSets,
    };

const _$CredentialFormatEnumMap = {
  CredentialFormat.jwtVcJson: 'jwt_vc_json',
  CredentialFormat.dcSdJwt: 'dc+sd-jwt',
  CredentialFormat.ldpVc: 'ldp_vc',
  CredentialFormat.msoMdoc: 'mso_mdoc',
  CredentialFormat.acVp: 'ac_vp',
};
