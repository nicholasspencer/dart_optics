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

  group('Lens', () {
    test('getter', () {
      expect(
        PersonOptics.address.getter(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        PersonOptics.addressName.getter(subject),
        equals('123 Capital of Texas Hwy'),
      );
    });

    test('get', () {
      expect(
        PersonOptics.address.get(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        PersonOptics.addressName.get(subject),
        equals('123 Capital of Texas Hwy'),
      );
    });

    test('setter', () {
      var newSubject = PersonOptics.address.setter(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(newSubject.address, equals(Address(streetName: '789 Mopac Expy')));

      newSubject = PersonOptics.addressName.setter(
        subject,
        '456 Research Blvd',
      );

      expect(newSubject.address.streetName, equals('456 Research Blvd'));
    });

    test('set', () {
      var newSubject = PersonOptics.address.set(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(newSubject.address, equals(Address(streetName: '789 Mopac Expy')));

      newSubject = PersonOptics.addressName.set(subject, '456 Research Blvd');

      expect(newSubject.address.streetName, equals('456 Research Blvd'));
    });

    test('asPrism get/set and null set is no-op for non-nullable', () {
      final address = Address(streetName: '123', buildingName: 'B1');
      final prism = AddressOptics.streetName.asPrism();

      expect(prism.get(address), '123');

      final updated = prism.set(address, '456');
      expect(updated.streetName, '456');

      // null should be a no-op because Focus is non-nullable String
      final unchanged = prism.set(address, null);
      expect(unchanged, address);
    });

    test('Lens-to-Lens compound works (Person.addressName)', () {
      final p = ApiPerson(
        name: 'John',
        address: Address(streetName: 'A'),
      );

      final lens = PersonOptics.addressName; // Lens<Person, String>
      expect(lens.get(p), equals('A'));

      final p2 = lens.set(p, 'B');
      expect(p2.address.streetName, equals('B'));
    });

    group('compound type guard', () {
      test('getter throws when Through is stricter than runtime value', () {
        final z = Zoo(Dog('Rex'));
        final composed = zooAnimal.compound<Cat, String>(catName);

        expect(() => composed.getter(z), throwsA(isA<ArgumentError>()));
      });

      test('setter is a no-op in the same mismatch', () {
        final z = Zoo(Dog('Rex'));
        final composed = zooAnimal.compound<Cat, String>(catName);

        final z2 = composed.setter(z, 'Mittens');
        expect(z2.animal, isA<Dog>());
        expect((z2.animal as Dog).name, equals('Rex'));
      });

      test('works when Through matches the runtime value', () {
        final z = Zoo(const Cat('Kitty'));
        final composed = zooAnimal.compound<Cat, String>(catName);

        final got = composed.get(z);
        expect(got, equals('Kitty'));

        final z2 = composed.set(z, 'Mittens');
        expect(z2.animal, isA<Cat>());
        expect((z2.animal as Cat).name, equals('Mittens'));
      });
    });

    test('compound with nullable lens (buildingName)', () {
      var addr = Address(streetName: 'Main St', buildingName: 'Tower A');

      expect(AddressOptics.buildingName.get(addr), 'Tower A');

      addr = AddressOptics.buildingName.set(addr, 'Tower B');
      expect(addr.buildingName, 'Tower B');

      addr = AddressOptics.buildingName.set(addr, null);
      expect(addr.buildingName, isNull);
    });
  });
}
