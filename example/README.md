# DCQL Examples

Check the sample code to learn how to use the DCQL library to query credentials from credential wallets.

| File | What it demonstrates |
| ---- | --------------------- |
| [`ldp_vc_basic_example.dart`](https://github.com/affinidi/affinidi-dcql-dart/tree/main/example/ldp_vc_basic_example.dart) | Query W3C (ldp_vc) credential by type + claim values |
| [`dc_sd_jwt_basic_example.dart`](https://github.com/affinidi/affinidi-dcql-dart/tree/main/example/dc_sd_jwt_basic_example.dart) | Query SD-JWT credential incl. selective disclosure & array paths |
| [`claim_sets_example.dart`](https://github.com/affinidi/affinidi-dcql-dart/tree/main/example/claim_sets_example.dart) | Using `claimSets` (OR of required claim combinations within one credential) |
| [`credential_sets_example.dart`](https://github.com/affinidi/affinidi-dcql-dart/tree/main/example/credential_sets_example.dart) | Using query‑level `credential_sets` (OR options across multiple credentials) |

## Running the Examples

Execute the example Dart script from the repository root folder:

```bash
dart run example/ldp_vc_basic_example.dart
dart run example/dc_sd_jwt_basic_example.dart
dart run example/claim_sets_example.dart
dart run example/credential_sets_example.dart
```

Each prints whether the query is fulfilled and which credential IDs matches.
