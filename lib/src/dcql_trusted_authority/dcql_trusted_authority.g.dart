// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_trusted_authority.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlTrustedAuthority _$DcqlTrustedAuthorityFromJson(
  Map<String, dynamic> json,
) => DcqlTrustedAuthority(
  type: $enumDecode(_$TrustedAuthorityTypeEnumMap, json['type']),
  values: (json['values'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$DcqlTrustedAuthorityToJson(
  DcqlTrustedAuthority instance,
) => <String, dynamic>{
  'type': _$TrustedAuthorityTypeEnumMap[instance.type]!,
  'values': instance.values,
};

const _$TrustedAuthorityTypeEnumMap = {
  TrustedAuthorityType.aki: 'aki',
  TrustedAuthorityType.etsiTl: 'etsi_tl',
  TrustedAuthorityType.openidFederation: 'openid_federation',
};
