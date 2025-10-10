import 'package:test/test.dart';
import 'package:dcql/dcql.dart';
import 'helpers/vc_test_data.dart';

void main() {
  group('CredentialSetMatchResult', () {
    group('multiple credential options', () {
      test(
          'should provide detailed matching information when user has multiple valid credentials',
          () {
        // Scenario: User has both a full driver's license and a passport,
        // verifier accepts either one as valid ID
        final driverLicense = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'DriversLicense'],
          credentialSubject: {
            'id': 'did:example:alice',
            'licenseNumber': 'DL123456789',
            'name': 'Alice Smith'
          },
        );

        final passport = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'Passport'],
          credentialSubject: {
            'id': 'did:example:alice',
            'passportNumber': 'P123456789',
            'name': 'Alice Smith'
          },
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
                id: 'drivers_license', format: CredentialFormat.ldpVc),
            DcqlCredential(id: 'passport', format: CredentialFormat.ldpVc),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['drivers_license'], // Option 1: Just driver's license
                ['passport'], // Option 2: Just passport
              ],
              required: true,
            ),
          ],
        );

        final result = query.query([driverLicense, passport]);

        // Should have detailed matching information
        expect(result.matchedCredentialSets, hasLength(1));

        final credSetResult = result.matchedCredentialSets.first;
        expect(credSetResult.setIndex, equals(0));
        expect(credSetResult.isSatisfied, isTrue);
        expect(credSetResult.matchedOptions, hasLength(2));

        // Both options should be satisfied (user has both credentials)
        expect(credSetResult.matchedOptions[0].credentialIdentifiers,
            equals(['drivers_license']));
        expect(credSetResult.matchedOptions[0].matches, isTrue);

        expect(credSetResult.matchedOptions[1].credentialIdentifiers,
            equals(['passport']));
        expect(credSetResult.matchedOptions[1].matches, isTrue);

        // Wallet can now offer user choice between driver's license or passport
        expect(credSetResult.satisfiedOptions, hasLength(2));
        expect(credSetResult.unsatisfiedOptions, isEmpty);
      });

      test(
          'should handle combination requirements with AND logic within options',
          () {
        // Scenario: Verifier needs BOTH birth certificate AND proof of address,
        // or a single government ID that contains both pieces of info
        final birthCert = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'BirthCertificate'],
          credentialSubject: {
            'id': 'did:example:bob',
            'birthDate': '1990-01-01',
            'birthPlace': 'New York, NY'
          },
        );

        final proofOfAddress = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'ProofOfAddress'],
          credentialSubject: {
            'id': 'did:example:bob',
            'address': '123 Main St, New York, NY 10001'
          },
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'birth_cert',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(typeValues: [
                ['BirthCertificate']
              ]),
            ),
            DcqlCredential(
              id: 'proof_address',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(typeValues: [
                ['ProofOfAddress']
              ]),
            ),
            DcqlCredential(
              id: 'govt_id_combo',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(typeValues: [
                ['GovernmentIDCombo']
              ]),
            ),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['birth_cert', 'proof_address'], // Option 1: Both documents
                ['govt_id_combo'], // Option 2: Single combo ID
              ],
              required: true,
            ),
          ],
        );

        final result = query.query([birthCert, proofOfAddress]);

        final credSetResult = result.matchedCredentialSets.first;
        expect(credSetResult.matchedOptions, hasLength(2));

        // First option (birth_cert + proof_address) should be satisfied
        expect(credSetResult.matchedOptions[0].credentialIdentifiers,
            equals(['birth_cert', 'proof_address']));
        expect(credSetResult.matchedOptions[0].matches, isTrue);

        // Second option (govt_id_combo) should NOT be satisfied (user doesn't have it)
        expect(credSetResult.matchedOptions[1].credentialIdentifiers,
            equals(['govt_id_combo']));
        expect(credSetResult.matchedOptions[1].matches, isFalse);

        expect(credSetResult.satisfiedOptions, hasLength(1));
        expect(credSetResult.unsatisfiedOptions, hasLength(1));
      });
    });

    group('optional credential sets', () {
      test(
          'should handle optional credential sets correctly when credentials are missing',
          () {
        // Scenario: Required ID plus optional membership card for discounts
        final driverLicense = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'DriversLicense'],
          credentialSubject: {
            'id': 'did:example:charlie',
            'licenseNumber': 'DL987654321'
          },
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
              id: 'id_document',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(typeValues: [
                ['DriversLicense']
              ]),
            ),
            DcqlCredential(
              id: 'membership_card',
              format: CredentialFormat.ldpVc,
              meta: DcqlMeta.forW3C(typeValues: [
                ['MembershipCard']
              ]),
            ),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['id_document']
              ],
              required: true,
            ),
            DcqlCredentialSet(
              options: [
                ['membership_card']
              ],
              required: false, // Optional
            ),
          ],
        );

        final result =
            query.query([driverLicense]); // Only has ID, no membership

        expect(result.matchedCredentialSets, hasLength(2));

        // Required set should be satisfied
        final requiredSet = result.matchedCredentialSets[0];
        expect(requiredSet.isSatisfied, isTrue);
        expect(requiredSet.satisfiedOptions, hasLength(1));

        // Optional set should still be "satisfied" even though credential is missing
        final optionalSet = result.matchedCredentialSets[1];
        expect(optionalSet.isSatisfied,
            isTrue); // Optional sets are always satisfied
        expect(optionalSet.satisfiedOptions, isEmpty); // But no actual matches
        expect(optionalSet.unsatisfiedOptions, hasLength(1));
      });
    });

    group('edge cases', () {
      test('should work when no credential sets are defined', () {
        final testCredential = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'TestCredential'],
          credentialSubject: {'id': 'did:example:test'},
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(id: 'test_cred', format: CredentialFormat.ldpVc),
          ],
          // No credentialSets defined
        );

        final result = query.query([testCredential]);

        expect(result.matchedCredentialSets, isEmpty);
        expect(result.fulfilled, isTrue); // Should still be fulfilled
      });

      test('should handle empty options gracefully', () {
        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(id: 'some_cred', format: CredentialFormat.ldpVc),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [], // Empty options
              required: false,
            ),
          ],
        );

        final result = query.query([]);

        expect(result.matchedCredentialSets, hasLength(1));
        expect(result.matchedCredentialSets.first.matchedOptions, isEmpty);
        expect(result.matchedCredentialSets.first.isSatisfied,
            isTrue); // Optional set
      });
    });

    group('data classes', () {
      test('should have working MatchedOption properties and toString', () {
        final option1 = MatchedOption(
          credentialIdentifiers: ['cred1', 'cred2'],
          matches: true,
        );

        final option2 = MatchedOption(
          credentialIdentifiers: ['cred1', 'cred2'],
          matches: false,
        );

        // Test properties
        expect(option1.credentialIdentifiers, equals(['cred1', 'cred2']));
        expect(option1.matches, isTrue);
        expect(option2.matches, isFalse);

        // Test toString
        expect(option1.toString(), contains('cred1'));
        expect(option1.toString(), contains('matches: true'));
        expect(option2.toString(), contains('matches: false'));
      });

      test('should have working CredentialSetMatchResult properties', () {
        final credentialSet = DcqlCredentialSet(
          options: [
            ['cred1'],
            ['cred2']
          ],
          required: true,
        );

        final matchedOptions = [
          MatchedOption(credentialIdentifiers: ['cred1'], matches: true),
          MatchedOption(credentialIdentifiers: ['cred2'], matches: false),
        ];

        final result = CredentialSetMatchResult(
          credentialSet: credentialSet,
          setIndex: 0,
          matchedOptions: matchedOptions,
        );

        expect(result.isSatisfied, isTrue);
        expect(result.satisfiedOptions, hasLength(1));
        expect(result.unsatisfiedOptions, hasLength(1));
        expect(result.toString(), contains('setIndex: 0'));
        expect(result.toString(), contains('satisfied: true'));
      });
    });

    group('wallet implementer use cases', () {
      test(
          'should enable wallet to present user choices for credential sharing',
          () {
        // Real-world scenario: Airport security accepts multiple forms of ID
        final driverLicense = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'DriversLicense'],
          credentialSubject: {'id': 'did:example:traveler', 'name': 'Jane Doe'},
        );

        final passport = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'Passport'],
          credentialSubject: {'id': 'did:example:traveler', 'name': 'Jane Doe'},
        );

        final militaryId = VcTestData.createW3CCredential(
          types: ['VerifiableCredential', 'MilitaryID'],
          credentialSubject: {'id': 'did:example:traveler', 'name': 'Jane Doe'},
        );

        final query = DcqlCredentialQuery(
          credentials: [
            DcqlCredential(
                id: 'drivers_license', format: CredentialFormat.ldpVc),
            DcqlCredential(id: 'passport', format: CredentialFormat.ldpVc),
            DcqlCredential(id: 'military_id', format: CredentialFormat.ldpVc),
          ],
          credentialSets: [
            DcqlCredentialSet(
              options: [
                ['drivers_license'],
                ['passport'],
                ['military_id'],
              ],
              required: true,
            ),
          ],
        );

        final result = query.query([driverLicense, passport, militaryId]);

        // Wallet implementation can now:
        final availableOptions =
            result.matchedCredentialSets.first.satisfiedOptions;
        expect(availableOptions, hasLength(3));

        // Show user: "Please select which ID to share:"
        // - Driver's License ✓
        // - Passport ✓
        // - Military ID ✓
        final userChoices = availableOptions
            .map((option) =>
                'Share: ${option.credentialIdentifiers.join(' + ')}')
            .toList();

        expect(userChoices, contains('Share: drivers_license'));
        expect(userChoices, contains('Share: passport'));
        expect(userChoices, contains('Share: military_id'));
      });
    });
  });
}
