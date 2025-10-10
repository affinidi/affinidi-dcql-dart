# Affinidi DCQL for Dart

The Affinidi DCQL library implements the Digital Credentials Query Language (DCQL, pronounced `[ˈdakl̩]` 📣) to simplify and enable verifiers to request credentials in a verifiable presentation format from a user's digital wallet. It is a JSON-encoded query language that defines the type of credentials that must be presented by the user, such as a verified identity credentials.

It is a flexible and granular standard query, enabling holders of credentials with enhanced security, privacy, and control to share their verifiable information selectively.

The DCQL library also leverages the open-sourced [SSI](https://pub.dev/packages/ssi) and [Selective Disclosure-JWT (SD-JWT)](https://pub.dev/packages/selective_disclosure_jwt) libraries by Affinidi to support data models from W3C and SD-JWT specifications.

## Table of Contents

- [Core Concepts](#core-concepts)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Query Specific Issuer Example](#query-specific-issuer-example)
  - [Query W3C Credential (ldp_vc) Example](#query-w3c-credential-ldp_vc-example)
  - [Query SD-JWT Credential (Array + Wildcard) Example](#query-sd-jwt-credential-array--wildcard-example)
- [DCQL Structure](#dcql-structure)
  - [Claim Path Semantics](#claim-path-semantics)
  - [Claim Sets (Per Credential)](#claim-sets-per-credential)
  - [Credential Sets (Query Level)](#credential-sets-query-level)
- [Interpreting Query Result](#interpreting-query-result)
- [Error Handling Notes](#error-handling-notes)
- [Extending Credential Format Support](#extending-credential-format-support)
- [Support & Feedback](#support--feedback)
  - [Reporting Technical Issues](#reporting-technical-issues)
- [Contributing](#contributing)


## Core Concepts

- **Verifiable Credential (VC):** A digital representation of a claim created by the issuer about the subject (e.g., Individual). VC is cryptographically signed and verifiable.

- **Verifiable Presentation (VP):** A collection of one or more Verifiable Credentials (VCs) that an individual shares with the verifier to prove specific claims. VP is cryptographically signed and verifiable.

- **Selective Disclosure:** Claims can be selectively disclosed based on the required verifiable presentation of the verifier.

## Key Features

- Support various credential formats, such as `ldp_vc` and `dc+sd-jwt`.
- Complex claim path evaluation, including arrays, wildcards, null or index.
- Support for querying credential sets, including exact match or matching from different values provided in the query.
- Support for filtering by metadata, like `type_values` (W3C) and `vct_values` (SD-JWT).

**NOTE:** This DCQL library does not include cryptographic operations such as signature verification and holder binding proof checks. It also does not include top‑level OpenID4VP request/response serialisation.


## Requirements

- Dart SDK version ^3.5.3

## Installation

Run:

```bash
dart pub add dcql
```

or manually, add the package into your `pubspec.yaml` file:

```yaml
dependencies:
  dcql: ^<version_number>
```

and then run the command below to install the package:

```bash
dart pub get
```

Visit the pub.dev install page of the Dart package for more information.

## Usage

Refer to the sample usage below on how to query a credential for specific requirements from the verifier.

### Query Specific Issuer Example

**Sample Verifiable Credential (VC):**

```json
{
   '@context': [
      'https://www.w3.org/2018/credentials/v1',
      'https://schema.affinidi.io/TEmailV1R0.jsonld',
   ],
   'credentialSchema': {
      'id': 'https://schema.affinidi.io/TEmailV1R0.json',
      'type': 'JsonSchemaValidator2018',
   },
   'credentialSubject': {'email': 'alice.doe@test.com'},
   'holder': {
      'id': 'did:key:zQ3shnHRFYxDpASTxaTFBMcqtFASxyzctDx8xYj2USw7QUaLb',
   },
   'id': 'claimId:ee3882a6b3058195',
   'issuanceDate': '2025-01-23T21:01:23.162Z',
   'issuer': 'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6',
   'proof': {
      'type': 'EcdsaSecp256k1Signature2019',
      'created': '2025-01-23T21:01:31Z',
      'verificationMethod':
         'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6#zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6',
      'proofPurpose': 'assertionMethod',
      'jws':
         'eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..ZwNL-5Gva80Xc0FR6v1R6wCVPPMAYzriWu6_szFD48YGPNQJPV66XsDHNjTGyQOyuRy7a3srX3diI5_1527Ttg',
   },
   'type': ['VerifiableCredential', 'Email'],
}
```

Given the sample credential above, using the DCQL library, we can query the user's digital wallet to request a credential issued by a specific issuer. 

For example, as an employer (verifier), you want to request the verified identity of a candidate applying for a job from a specific background screening company.

You can do this by querying the Verifiable Credentials (VC) stored in the user's digital wallet with the `issuer` field using the published DID of the background screening company that issued the credential.

```dart
import 'package:dcql/src/dcql_base.dart';
import 'package:ssi/ssi.dart';

void main() async {
  final verifiableCredentials = [
    VcDataModelV1.fromJson(<SAMPLE_CREDENTIALS>),
  ];

  final issuerQuery = DcqlCredentialQuery(
    credentials: [
      DcqlCredential(
        id: 'pid',
        format: CredentialFormat.ldpVc,
        claims: [
          DcqlClaim(
            path: ['issuer', 'id'],
            values: [
              'did:key:zQ3shXLA2cHanJgCUsDfXxBi2BGnMLArHVz5NWoC9axr8pEy6'
            ],
          ),
        ],
      ),
    ],
  );
  final issuerResult = issuerQuery.query(digitalCredentials);
  print('Query issuer');
  print('Fulfilled: ${issuerResult.fulfilled}');
  print('VCs: ${issuerResult.verifiableCredentials}');
}

```

### Query W3C Credential (ldp_vc) Example

```dart
final query = DcqlCredentialQuery(
  credentials: [
    DcqlCredential(
      id: 'pid',
      format: CredentialFormat.ldpVc,
      meta: DcqlMeta.forW3C(typeValues: [ ['Email'] ]),
      claims: [
        DcqlClaim(
          path: ['credentialSubject','email'],
          values: ['alice.doe@test.com'],
        ),
      ],
    ),
  ],
);
final vcs = [
  W3CDigitalCredential.fromLdVcDataModelV1(yourVcJsonMap),
];
final result = query.query(vcs);
print(result.fulfilled); // true if matched
```

### Query SD-JWT Credential (Array + Wildcard) Example

```dart
final query = DcqlCredentialQuery(
  credentials: [
    DcqlCredential(
      id: 'pid',
      format: CredentialFormat.dcSdJwt,
      claims: [
        DcqlClaim(path: ['given_name'], values: ['Alice']),
        DcqlClaim(path: ['citizenship', null, 'country'], values: ['Germany']),
      ],
    ),
  ],
);
final sdJwt = await SdJwtHandlerV1().sign(/* ... */);
final result = query.query([SdJwtDigitalCredential.fromSdJwt(sdJwt)]);
```

If there's a match from the query, it returns the Verifiable Credential/s (VCs) to generate a Verifiable Presentation (VP) format for the verifier to parse and verify.

For more examples of how to query credentials using the DCQL Dart library, refer to the [example folder](https://github.com/affinidi/affinidi-dcql-dart/tree/main/example).


## DCQL Structure

DCQL structure when creating a query.

### Claim Path Semantics

**`path`** is an array of segments that specifies how to navigate through the credential’s JSON structure. Each item in the array represents a key or index to locate the value, starting from the root.

- `null` segment inside a list is a *wildcard*. First element for which the remaining path resolves non‑null.
- Integer segment inside a list is a fixed index.

**Examples:**

- `["credentialSubject", "email"]` → simple property
- `["citizenship", null, "country"]` → any array element whose `country` matches
- `["education", 0, "masterDegree"]` → first array element’s `masterDegree`

### Claim Sets (Per Credential)

`claimSets: [["name","age"], ["email"]]` - in this example, the credential matches if (`name` AND `age`) are satisfied OR (`email`) is satisfied.

### Credential Sets (Query Level)

**`credential_sets`** is a collection of one or more credentials (called `options`) that are evaluated together during a query. The query succeeds if one of the options satisfies the requirements.

## Interpreting Query Result

Refer to the table below on interpreting the `DcqlQueryResult` from executing a DCQL query.

|Field | Meaning|
|------|--------|
|`fulfilled` | Overall boolean according to credential + query sets. |
|`verifiableCredentials` | Map: credential ID → iterable of matched DigitalCredential(s). |
|`satisfiedClaimsByCredential` | (Optional) VC evidence of which claim IDs were satisfied (used when claimSets is present). |

## Error Handling Notes

Existing validation helpers:

- `DcqlClaim.validate()`
- `DcqlCredential.validate()`
- `DcqlMeta.validate()`

Detailed spec error taxonomy implementation is unavailable; expect simple validation failure aggregation.

## Extending Credential Format Support

To add new credential format support, implement the [`DigitalCredential` interface](https://github.com/affinidi/affinidi-dcql-dart/blob/main/lib/src/digital_credential/digital_credential_interface.dart) and then extend matching [`DcqlCredentialQuery`](https://github.com/affinidi/affinidi-dcql-dart/blob/main/lib/src/dcql_credential_query/dcql_credential_query.dart) meta.

Go to the [SD-JWT implementation](https://github.com/affinidi/affinidi-dcql-dart/blob/main/lib/src/digital_credential/sd_jwt) for reference.

## Support & Feedback

If you face any issues or have suggestions, please don't hesitate to contact us using [this link](https://share.hsforms.com/1i-4HKZRXSsmENzXtPdIG4g8oa2v).

### Reporting Technical Issues

If you have a technical issue with the DCQL's codebase, you can also create an issue directly in GitHub.

1. Ensure the bug was not already reported by searching on GitHub under
   [Issues](https://github.com/affinidi/affinidi-dcql-dart/issues).

2. If you're unable to find an open issue addressing the problem,
   [open a new one](https://github.com/affinidi/affinidi-dcql-dart/issues/new).
   Be sure to include a **title and clear description**, as much relevant information as possible,
   and a **code sample** or an **executable test case** demonstrating the expected behaviour that is not occurring.

## Contributing

Want to contribute?

Head over to our [CONTRIBUTING](https://github.com/affinidi/affinidi-dcql-dart/blob/main/CONTRIBUTING.md) guidelines.
