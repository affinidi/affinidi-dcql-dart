import 'package:dcql/src/dcql_credential/dcql_credential.dart';
import 'package:dcql/src/dcql_credential_query/dcql_credential_query.dart';
import 'package:dcql/src/dcql_query_result/dcql_query_result.dart';
import 'package:dcql/src/credential_format/credential_format.dart';
import 'package:dcql/src/dcql_claim/dcql_claim.dart';
import 'package:dcql/src/dcql_credential_set/dcql_credential_set.dart';
import 'package:dcql/src/digital_credential/w3c/credential/w3c_digital_credential.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('DcqlQueryResult', () {
    late DcqlCredentialQuery query;
    late W3CDigitalCredential vc1;
    late W3CDigitalCredential vc2;

    setUp(() {
      query = DcqlCredentialQuery(
        credentials: [
          DcqlCredential(
            id: 'cred1',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(
                id: 'name',
                path: ['credentialSubject', 'name'],
                values: ['Alice'],
              ),
            ],
          ),
          DcqlCredential(
            id: 'cred2',
            format: CredentialFormat.ldpVc,
            claims: [
              DcqlClaim(
                id: 'email',
                path: ['credentialSubject', 'email'],
                values: ['alice@example.com'],
              ),
            ],
          ),
        ],
      );

      vc1 = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'PersonCredential'],
        credentialSubject: {'name': 'Alice', 'email': 'alice@example.com'},
        id: 'urn:uuid:1',
      );

      vc2 = VcTestData.createW3CCredential(
        types: ['VerifiableCredential', 'EmailCredential'],
        credentialSubject: {'name': 'Bob', 'email': 'bob@example.com'},
        id: 'urn:uuid:2',
      );
    });

    group('fulfilled property', () {
      test('should return true when all credentials are matched', () {
        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc1],
            'cred2': [vc2],
          },
        );

        expect(result.fulfilled, isTrue);
      });

      test('should return false when some credentials are missing', () {
        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc1],
          },
        );

        expect(result.fulfilled, isFalse);
      });

      test('should return false when no credentials are matched', () {
        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {},
        );

        expect(result.fulfilled, isFalse);
      });

      test('should handle claim sets correctly when satisfied claims provided',
          () {
        final queryWithClaimSets = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred1',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                    id: 'name',
                    path: ['credentialSubject', 'name'],
                    values: ['Alice']),
                DcqlClaim(
                    id: 'email',
                    path: ['credentialSubject', 'email'],
                    values: ['alice@example.com']),
              ],
              claimSets: [
                ['name', 'email'],
              ],
            ),
          ],
        );

        final resultWithEvidence = DcqlQueryResult(
          query: queryWithClaimSets,
          verifiableCredentials: {
            'cred1': [vc1],
          },
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name', 'email'},
            ],
          },
        );
        expect(resultWithEvidence.fulfilled, isTrue);

        final resultIncomplete = DcqlQueryResult(
          query: queryWithClaimSets,
          verifiableCredentials: {
            'cred1': [vc1],
          },
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name'},
            ],
          },
        );
        expect(resultIncomplete.fulfilled, isFalse);
      });

      test(
          'should fall back to true when no satisfied claims evidence but VC matched',
          () {
        final queryWithClaimSets = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'cred1',
              format: CredentialFormat.ldpVc,
              claims: [
                DcqlClaim(
                    id: 'name',
                    path: ['credentialSubject', 'name'],
                    values: ['Alice']),
                DcqlClaim(
                    id: 'email',
                    path: ['credentialSubject', 'email'],
                    values: ['alice@example.com']),
              ],
              claimSets: [
                ['name', 'email'],
              ],
            ),
          ],
        );

        final result = DcqlQueryResult(
          query: queryWithClaimSets,
          verifiableCredentials: {
            'cred1': [vc1],
          },
        );
        expect(result.fulfilled, isTrue);
      });

      test('should handle credential sets correctly', () {
        final queryWithCredentialSets = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(id: 'cred1', format: CredentialFormat.ldpVc),
            DcqlCredential(id: 'cred2', format: CredentialFormat.ldpVc),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['cred1'],
                ['cred2'],
              ],
            ),
          ],
        );

        final result = DcqlQueryResult(
          query: queryWithCredentialSets,
          verifiableCredentials: {
            'cred1': [vc1],
          },
        );
        expect(result.fulfilled, isTrue);

        final resultEmpty = DcqlQueryResult(
          query: queryWithCredentialSets,
          verifiableCredentials: {},
        );
        expect(resultEmpty.fulfilled, isFalse);
      });
    });

    group('combine method', () {
      test('should combine multiple results with same query', () {
        final result1 = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc1],
          },
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name'},
            ],
          },
        );

        final result2 = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred2': [vc2],
          },
          satisfiedClaimsByCredential: {
            'cred2': [
              {'email'},
            ],
          },
        );

        final combined = DcqlQueryResult.combine([result1, result2]);

        expect(combined.query, query);
        expect(combined.verifiableCredentials.keys, contains('cred1'));
        expect(combined.verifiableCredentials.keys, contains('cred2'));
        expect(combined.satisfiedClaimsByCredential['cred1'], hasLength(1));
        expect(combined.satisfiedClaimsByCredential['cred2'], hasLength(1));
      });

      test(
          'should throw exception when combining results with different queries',
          () {
        final query1 = DcqlCredentialQuery(credentials: [
          DcqlCredential(id: 'cred1', format: CredentialFormat.ldpVc),
        ]);
        final query2 = DcqlCredentialQuery(credentials: [
          DcqlCredential(id: 'cred2', format: CredentialFormat.ldpVc),
        ]);

        final result1 = DcqlQueryResult(query: query1);
        final result2 = DcqlQueryResult(query: query2);

        expect(
          () => DcqlQueryResult.combine([result1, result2]),
          throwsA(isA<Exception>()),
        );
      });

      test('should combine satisfied claims correctly', () {
        final result1 = DcqlQueryResult(
          query: query,
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name'},
            ],
          },
        );

        final result2 = DcqlQueryResult(
          query: query,
          satisfiedClaimsByCredential: {
            'cred1': [
              {'email'},
            ],
          },
        );

        final combined = DcqlQueryResult.combine([result1, result2]);
        final cred1Claims = combined.satisfiedClaimsByCredential['cred1']!;

        expect(cred1Claims, hasLength(2));
        expect(cred1Claims.any((s) => s.contains('name')), isTrue);
        expect(cred1Claims.any((s) => s.contains('email')), isTrue);
      });

      test('should combine unsatisfied credentials', () {
        final unsatisfiedCred1 =
            DcqlCredential(id: 'cred1', format: CredentialFormat.ldpVc);
        final unsatisfiedCred2 =
            DcqlCredential(id: 'cred2', format: CredentialFormat.ldpVc);

        final result1 = DcqlQueryResult(
          query: query,
          unsatisfiedQueryCredentialSets: [unsatisfiedCred1],
        );

        final result2 = DcqlQueryResult(
          query: query,
          unsatisfiedQueryCredentialSets: [unsatisfiedCred2],
        );

        final combined = DcqlQueryResult.combine([result1, result2]);

        expect(combined.unsatisfiedQueryCredentialSets, hasLength(2));
        expect(combined.unsatisfiedQueryCredentialSets,
            contains(unsatisfiedCred1));
        expect(combined.unsatisfiedQueryCredentialSets,
            contains(unsatisfiedCred2));
      });
    });

    group('edge cases', () {
      test('should handle empty verifiable credentials', () {
        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {},
        );

        expect(result.verifiableCredentials, isEmpty);
        expect(result.fulfilled, isFalse);
      });

      test('should handle empty satisfied claims', () {
        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc1],
          },
          satisfiedClaimsByCredential: {},
        );

        expect(result.satisfiedClaimsByCredential, isEmpty);
      });

      test('should handle empty unsatisfied credentials', () {
        final result = DcqlQueryResult(
          query: query,
          unsatisfiedQueryCredentialSets: [],
        );

        expect(result.unsatisfiedQueryCredentialSets, isEmpty);
      });
    });
  });
}
