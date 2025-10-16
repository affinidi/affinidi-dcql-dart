// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_credential_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlCredentialQuery _$DcqlCredentialQueryFromJson(Map<String, dynamic> json) =>
    DcqlCredentialQuery(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => DcqlCredential.fromJson(e as Map<String, dynamic>)),
      credentialSets: (json['credential_sets'] as List<dynamic>?)
          ?.map((e) => DcqlCredentialSet.fromJson(e as Map<String, dynamic>)),
    );

Map<String, dynamic> _$DcqlCredentialQueryToJson(
        DcqlCredentialQuery instance) =>
    <String, dynamic>{
      'credentials': instance.credentials.map((e) => e.toJson()).toList(),
      if (instance.credentialSets?.map((e) => e.toJson()).toList()
          case final value?)
        'credential_sets': value,
    };
