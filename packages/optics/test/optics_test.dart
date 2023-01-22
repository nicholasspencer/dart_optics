import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  late Person subject;

  setUp(() {
    subject = Person(
      name: 'John',
      address: Address(
        streetName: '123 Capital of Texas Hwy',
      ),
      job: Job(
        title: 'Sandwich Artist',
        address: Address(
          streetName: '456 Mesa Dr',
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
            ),
          ),
        ),
      );

      expect(
        PersonOptics.job
            .compound(JobOptics.address.asPrism())
            .compound(AddressOptics.streetName.asPrism())
            .getter(subject),
        '456 Mesa Dr',
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
            ),
          ),
        ),
      );

      expect(
        PersonOptics.job
            .compound(JobOptics.address.asPrism())
            .compound(AddressOptics.streetName.asPrism())
            .get(subject),
        '456 Mesa Dr',
      );
    });

    test('setter', () {
      subject = PersonOptics.address.setter(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

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
          .compound(JobOptics.address.asPrism())
          .compound(AddressOptics.streetName.asPrism())
          .setter(subject, '124 Research Blvd');

      expect(
        subject.job?.address.streetName,
        '124 Research Blvd',
      );
    });

    test('mutate', () {
      subject = PersonOptics.address.set(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

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
          .compound(JobOptics.address.asPrism())
          .compound(AddressOptics.streetName.asPrism())
          .set(subject, '124 Research Blvd');

      expect(
        subject.job?.address.streetName,
        equals('124 Research Blvd'),
      );
    });

    test('map', () {
      expect(
        PersonOptics.address
            .compound(AddressOptics.streetName)
            .map(
              source: subject,
              map: (focus) => focus.toUpperCase(),
            )
            .address
            .streetName,
        equals('123 CAPITAL OF TEXAS HWY'),
      );
    });
  });
  group('Bound', () {
    test('call', () {
      expect(
        subject.addressOptic.compound(AddressOptics.streetName)(),
        equals('123 Capital of Texas Hwy'),
      );
      expect(
        subject.jobOptic.compound(JobOptics.title.asPrism())(),
        'Sandwich Artist',
      );
    });

    test('mutate', () {
      subject = subject.addressOptic
          .compound(AddressOptics.streetName)
          .set('789 Mopac Expy');

      expect(subject.address.streetName, equals('789 Mopac Expy'));

      subject = subject.jobOptic
          .compound(JobOptics.title.asPrism())
          .set('Software Engineer');

      expect(subject.job?.title, 'Software Engineer');
    });

    test('map', () {
      expect(
        subject.addressOptic
            .compound(AddressOptics.streetName)
            .map((focus) => focus.toUpperCase())
            .address
            .streetName,
        equals('123 CAPITAL OF TEXAS HWY'),
      );
    });
  });
}
