import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:dcql/src/dcql_trusted_authority/dcql_trusted_authority.dart';
import 'package:json_annotation/json_annotation.dart';
import '../dcql_meta/dcql_meta.dart';
import '../validation_result/validation_result.dart';

part 'dcql_credential.g.dart';

/// The Credential class represents a entry in credentials array of the CredentialQuery.
/// [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-credential-query).
@JsonSerializable(includeIfNull: false)
class DcqlCredential {
  /// a string identifying the Credential in the response and,
  /// if provided, the constraints in credential_sets.
  /// The value MUST be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.
  /// Within the Authorization Request, the same id MUST NOT be present more than once.
  final String id;

  /// [format] - an enum that specifies the format of the requested Verifiable Credential.
  final CredentialFormat format;

  /// a boolean which indicates whether multiple Credentials can be returned for this Credential Query.
  /// If omitted, the default value is false
  @JsonKey(defaultValue: false)
  final bool multiple;

  /// an object defining additional properties requested by the Verifier
  /// that apply to the metadata and validity data of the Credential.
  /// If omitted, no specific constraints are placed on the metadata or validity of the requested Credential.
  final DcqlMeta? meta;

  /// a non-empty array expected authorities or trust frameworks that certify Issuers,
  /// that the Verifier will accept. Every Credential returned by the Wallet SHOULD match at least one of the conditions present
  /// in the corresponding trusted_authorities array if present.
  @JsonKey(name: 'trusted_authorities')
  final List<DcqlTrustedAuthority>? trustedAuthorities;

  /// a boolean which indicates whether the Verifier requires a Cryptographic Holder Binding proof.
  /// The default value is true, i.e., a Verifiable Presentation with Cryptographic Holder Binding is required.
  /// If set to false, the Verifier accepts a Credential without Cryptographic Holder Binding proof.
  @JsonKey(name: 'require_cryptographic_holder_binding')
  final bool? requireCryptographicHolderBinding;

  /// a non-empty array of claims in the requested Credential.
  /// Verifiers MUST NOT point to the same claim more than once in a single query.
  /// Wallets SHOULD ignore such duplicate claim queries.
  final List<DcqlClaim>? claims;

  /// a non-empty array containing arrays of identifiers for elements in claims
  /// that specifies which combinations of claims for the Credential are requested.
  @JsonKey(name: 'claim_sets')
  final List<List<String>>? claimSets;

  /// Creates a Credential object. [Spec](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-credential-query).
  DcqlCredential({
    required this.id,
    required this.format,
    this.multiple = false,
    this.meta,
    this.trustedAuthorities,
    this.requireCryptographicHolderBinding = true,
    this.claims,
    this.claimSets,
  });

  /// Validates the DcqlCredential instance according to the DCQL specification.
  ///
  /// This method performs the following validations:
  /// - Validates the id format (alphanumeric, underscore, hyphen only)
  /// - Validates metadata constraints for the specified credential format
  /// - Validates all claims and their relationships with claim sets
  ///
  /// Returns a [ValidationResult] containing any validation errors found.
  ValidationResult validate() {
    final result = ValidationResult();
    final idPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

    if (id.isEmpty || !idPattern.hasMatch(id)) {
      result.addError(
        'Invalid id: must be a non-empty string consisting of alphanumeric, underscore (_) or hyphen (-) characters.',
      );
    }

    if ((claims == null || claims!.isEmpty) && claimSets != null) {
      result.addError('claimSets is provided but claims is null or empty.');
    }

    result.combine(meta?.validate(format: format));

    if (claims != null) {
      for (final claim in claims!) {
        result.combine(claim.validate(claims: claims, claimSets: claimSets));
      }
    }

    return result;
  }

  /// Creates a DcqlCredential instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing DcqlCredential objects
  /// from JSON data, typically received from API responses or configuration files.
  factory DcqlCredential.fromJson(Map<String, dynamic> json) =>
      _$DcqlCredentialFromJson(json);

  /// Converts this DcqlCredential instance to a JSON map.
  ///
  /// This method is used for serializing DcqlCredential objects to JSON format,
  /// typically for API requests or configuration storage.
  Map<String, dynamic> toJson() => _$DcqlCredentialToJson(this);
}
