import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  late Person subject;

  setUp(() {
    subject = Person(
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

  group('Optic', () {
    test('getter', () {
      expect(
        PersonOptics.address.getter(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        PersonOptics.job.getter(subject),
        equals(
          Job(
            title: 'Sandwich Artist',
            address: Address(
              streetName: '456 Mesa Dr',
              buildingName: 'UsedToBeATacoBell',
            ),
          ),
        ),
      );

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

    test('view', () {
      expect(
        PersonOptics.address.get(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        PersonOptics.job.get(subject),
        equals(
          Job(
            title: 'Sandwich Artist',
            address: Address(
              streetName: '456 Mesa Dr',
              buildingName: 'UsedToBeATacoBell',
            ),
          ),
        ),
      );

      expect(
        PersonOptics.job
            .compound(JobOptics.address)
            .compound(AddressOptics.streetName)
            .get(subject),
        '456 Mesa Dr',
      );
    });

    test('setter', () {
      subject = PersonOptics.address.setter(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(subject.address, equals(Address(streetName: '789 Mopac Expy')));

      subject = PersonOptics.job.setter(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        subject.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      subject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .setter(subject, '124 Research Blvd');

      expect(subject.job?.address.streetName, '124 Research Blvd');

      subject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .setter(subject, null);

      expect(subject.job?.address.streetName, '124 Research Blvd');
    });

    test('mutate', () {
      subject = PersonOptics.address.set(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(subject.address, equals(Address(streetName: '789 Mopac Expy')));

      subject = PersonOptics.job.set(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        subject.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      subject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .set(subject, '124 Research Blvd');

      expect(subject.job?.address.streetName, equals('124 Research Blvd'));

      subject = PersonOptics.job
          .compound(JobOptics.address)
          .compound(AddressOptics.streetName)
          .set(subject, null);

      expect(subject.job?.address.streetName, equals('124 Research Blvd'));
    });

    test('map', () {
      expect(
        PersonOptics.address
            .compound(AddressOptics.streetName)
            .map(source: subject, map: (focus) => focus.toUpperCase())
            .address
            .streetName,
        equals('123 CAPITAL OF TEXAS HWY'),
      );
    });
  });
}
