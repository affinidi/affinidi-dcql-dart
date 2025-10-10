import 'package:dcql/dcql.dart';
import 'package:test/test.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('ClaimSets matching', () {
    final vcSet1 = VcTestData.createW3CCredential(
      types: ['VerifiableCredential', 'NameCredential'],
      credentialSubject: {
        'name': 'Alice',
      },
      id: 'urn:uuid:1',
    );
    final vcSet2 = VcTestData.createW3CCredential(
      types: ['VerifiableCredential', 'EmailCredential'],
      credentialSubject: {'email': 'alice@example.com'},
      id: 'urn:uuid:2',
    );
    final vcSet3 = VcTestData.createW3CCredential(
      types: ['VerifiableCredential', 'AgeCredential'],
      credentialSubject: {'age': 30},
      id: 'urn:uuid:3',
    );

    final cred = DcqlCredential(
      id: 'cred1',
      format: CredentialFormat.ldpVc,
      claims: [
        DcqlClaim(
          id: 'name',
          path: ['credentialSubject', 'name'],
          values: ['Alice'],
        ),
        DcqlClaim(
          id: 'age',
          path: ['credentialSubject', 'age'],
          values: [30],
        ),
        DcqlClaim(
          id: 'email',
          path: ['credentialSubject', 'email'],
          values: ['alice@example.com'],
        ),
      ],
      // Either name+age OR email must be present in a single VC
      claimSets: [
        ['name', 'age'],
        ['email'],
      ],
      meta: DcqlMeta.forW3C(
        typeValues: [
          ['NameCredential'],
          ['AgeCredential'],
          ['EmailCredential'],
        ],
      ),
    );

    group('single credential matching', () {
      test('should match VC satisfying one claim_set option', () {
        final query = DcqlCredentialQuery(credentials: [cred]);
        final result = query.query([vcSet1, vcSet2, vcSet3]);

        expect(result.fulfilled, isTrue);
        expect(result.verifiableCredentials['cred1']!.length, 1);
      });
    });

    group('satisfiedClaims evidence validation', () {
      test(
          'should return false when evidence lacks complete required claim_set',
          () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(
              id: 'name',
              path: ['credentialSubject', 'name'],
              values: ['Alice'],
            ),
            DcqlClaim(
              id: 'age',
              path: ['credentialSubject', 'age'],
              values: [30],
            ),
          ],
          claimSets: [
            ['name', 'age'],
          ],
        );

        final query = DcqlCredentialQuery(credentials: [cred]);
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'PersonCredential'],
          credentialSubject: {'name': 'Alice', 'age': 30},
          id: 'urn:uuid:3',
        );

        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc],
          },
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name'}.toSet(), // missing 'age' so requirement not met
            ],
          },
        );
        expect(result.fulfilled, isFalse);
      });

      test('should fall back to true when no evidence but VC matched upstream',
          () {
        final cred = DcqlCredential(
          id: 'cred1',
          format: CredentialFormat.ldpVc,
          claims: [
            DcqlClaim(
              id: 'name',
              path: ['credentialSubject', 'name'],
              values: ['Alice'],
            ),
            DcqlClaim(
              id: 'age',
              path: ['credentialSubject', 'age'],
              values: [30],
            ),
          ],
          claimSets: [
            ['name', 'age'],
          ],
        );

        final query = DcqlCredentialQuery(credentials: [cred]);
        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'PersonCredential'],
          credentialSubject: {'name': 'Alice', 'age': 30},
          id: 'urn:uuid:4',
        );

        final result = DcqlQueryResult(
          query: query,
          verifiableCredentials: {
            'cred1': [vc],
          },
        );
        expect(result.fulfilled, isTrue);
      });
    });

    group('credential sets evaluation', () {
      test(
          'should fail when required set needs both credentials but one is missing',
          () {
        final credA =
            DcqlCredential(id: 'A', format: CredentialFormat.ldpVc, claims: [
          DcqlClaim(
            id: 'name',
            path: ['credentialSubject', 'name'],
            values: ['Alice'],
          ),
          DcqlClaim(
            id: 'age',
            path: ['credentialSubject', 'age'],
            values: [30],
          ),
        ]);
        final credB =
            DcqlCredential(id: 'B', format: CredentialFormat.ldpVc, claims: [
          DcqlClaim(
            id: 'name',
            path: ['credentialSubject', 'name'],
            values: ['Bob'],
          ),
          DcqlClaim(
            id: 'age',
            path: ['credentialSubject', 'age'],
            values: [25],
          ),
        ]);

        final query = DcqlCredentialQuery(
          credentials: [credA, credB],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['A', 'B'],
              ],
            ),
          ],
        );

        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'Misc'],
          credentialSubject: {
            'name': 'Alice',
            'age': 30,
          },
          id: 'urn:uuid:5',
        );

        final result = query.query([vc]);
        expect(result.fulfilled, isFalse);
      });

      test(
          'should fulfill required set with OR options when single match exists',
          () {
        final credA =
            DcqlCredential(id: 'A', format: CredentialFormat.ldpVc, claims: [
          DcqlClaim(
            id: 'name',
            path: ['credentialSubject', 'name'],
            values: ['Alice'],
          ),
          DcqlClaim(
            id: 'age',
            path: ['credentialSubject', 'age'],
            values: [30],
          ),
        ]);
        final credB =
            DcqlCredential(id: 'B', format: CredentialFormat.ldpVc, claims: [
          DcqlClaim(
            id: 'name',
            path: ['credentialSubject', 'name'],
            values: ['Bob'],
          ),
          DcqlClaim(
            id: 'age',
            path: ['credentialSubject', 'age'],
            values: [25],
          ),
        ]);

        final query = DcqlCredentialQuery(
          credentials: [credA, credB],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['A'],
                ['B'],
              ],
            ),
          ],
        );

        final vc = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'Misc'],
          credentialSubject: {
            'name': 'Alice',
            'age': 30,
          },
          id: 'urn:uuid:6',
        );

        final result = query.query([vc]);
        expect(result.fulfilled, isTrue);
        expect(result.verifiableCredentials['A']!.length, 1);
      });
    });

    group('combine() method', () {
      test('should concatenate satisfiedClaimsByCredential lists', () {
        final cred =
            DcqlCredential(id: 'cred1', format: CredentialFormat.ldpVc);
        final query = DcqlCredentialQuery(credentials: [cred]);

        final result1 = DcqlQueryResult(
          query: query,
          satisfiedClaimsByCredential: {
            'cred1': [
              {'name'}.toSet(),
            ],
          },
        );

        final result2 = DcqlQueryResult(
          query: query,
          satisfiedClaimsByCredential: {
            'cred1': [
              {'age'}.toSet(),
            ],
          },
        );

        final combined = DcqlQueryResult.combine([result1, result2]);
        final lists = combined.satisfiedClaimsByCredential['cred1']!;
        expect(lists.length, 2);
        expect(lists.any((s) => s.contains('name')), isTrue);
        expect(lists.any((s) => s.contains('age')), isTrue);
      });
    });
  });
}
