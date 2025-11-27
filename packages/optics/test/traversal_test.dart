import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  late ApiPerson subject;

  setUp(() {
    subject = ApiPerson(
      name: 'John',
      address: Address(streetName: '123 Capital of Texas Hwy'),
      job: Job(
        title: 'Sandwich Artist',
        address: Address(
          streetName: '456 Mesa Dr',
          buildingName: 'UsedToBeATacoBell',
        ),
      ),
    );
  });

  group('AffineTraversal', () {
    test('getter with nested optics', () {
      expect(
        PersonOptics.job
            .compound(JobOptics.address)
            .compound(AddressOptics.streetName)
            .getter(subject),
        '456 Mesa Dr',
      );

      expect(
        PersonOptics.worksInBuildingName.getter(subject),
        'UsedToBeATacoBell',
      );
    });

    test('get with nested optics', () {
      expect(
        PersonOptics.job
            .compound(JobOptics.address)
            .compound(AddressOptics.streetName)
            .get(subject),
        '456 Mesa Dr',
      );

      expect(
        PersonOptics.worksInBuildingName.get(subject),
        'UsedToBeATacoBell',
      );
    });

    test('setter with nested optics', () {
      var newSubject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .setter(subject, '124 Research Blvd');

      expect(newSubject.job?.address.streetName, '124 Research Blvd');

      // Setting null when final lens is non-nullable should be no-op
      newSubject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .setter(subject, null);

      expect(newSubject.job?.address.streetName, '456 Mesa Dr');
    });

    test('set with nested optics', () {
      var newSubject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .set(subject, '124 Research Blvd');

      expect(newSubject.job?.address.streetName, equals('124 Research Blvd'));

      // Setting null when final lens is non-nullable should be no-op
      newSubject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .set(subject, null);

      expect(newSubject.job?.address.streetName, equals('456 Mesa Dr'));
    });

    test('Null propagation when source Focus is absent', () {
      final personWithoutJob = ApiPerson(
        name: 'John',
        address: Address(streetName: '123'),
        job: null,
      );

      final trav = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName);

      expect(trav.get(personWithoutJob), isNull);

      final unchanged = trav.set(personWithoutJob, 'New St');
      expect(
        unchanged,
        equals(personWithoutJob),
      ); // source unchanged because job is null
    });

    test(
      'Setting nullable focus to null updates when last Lens is nullable',
      () {
        var testSubject = ApiPerson(
          name: 'John',
          address: Address(streetName: '123'),
          job: Job(
            title: 'Artist',
            address: Address(
              streetName: '456',
              buildingName: 'UsedToBeATacoBell',
            ),
          ),
        );

        // This traversal ends at Address.buildingName (nullable).
        final trav = PersonOptics.worksInBuildingName;

        expect(trav.get(testSubject), equals('UsedToBeATacoBell'));

        testSubject = trav.set(testSubject, 'HQ');
        expect(testSubject.job?.address.buildingName, equals('HQ'));

        // Since the last lens is nullable, setting null should clear it.
        testSubject = trav.set(testSubject, null);
        expect(testSubject.job?.address.buildingName, isNull);
      },
    );

    test('Complex nested traversals work as expected', () {
      // Test the predefined worksInBuildingName traversal
      expect(
        PersonOptics.worksInBuildingName.get(subject),
        'UsedToBeATacoBell',
      );

      var newSubject = PersonOptics.worksInBuildingName.set(
        subject,
        'New Building',
      );
      expect(newSubject.job?.address.buildingName, 'New Building');

      // Test null propagation
      final personWithoutJob = ApiPerson(
        name: 'Jane',
        address: Address(streetName: 'Main St'),
        job: null,
      );

      expect(PersonOptics.worksInBuildingName.get(personWithoutJob), isNull);

      final unchanged = PersonOptics.worksInBuildingName.set(
        personWithoutJob,
        'Tower',
      );
      expect(unchanged.job, isNull);
    });

    test('Multiple level traversal chains', () {
      // Test jobTitle traversal
      expect(PersonOptics.jobTitle.get(subject), 'Sandwich Artist');

      var newSubject = PersonOptics.jobTitle.set(subject, 'Senior Developer');
      expect(newSubject.job?.title, 'Senior Developer');

      // Test jobAddressName traversal
      expect(PersonOptics.jobAddressName.get(subject), '456 Mesa Dr');

      newSubject = PersonOptics.jobAddressName.set(subject, 'Oak Street');
      expect(newSubject.job?.address.streetName, 'Oak Street');
    });
  });
}
