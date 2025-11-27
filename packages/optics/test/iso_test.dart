import 'package:optics/optics.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('Iso', () {
    test('Iso.identity get/set', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();

      final p = ApiPerson(
        name: 'A',
        address: Address(streetName: 'X'),
      );

      expect(identity.get(p), equals(p));

      final p2 = p.copyWith(name: 'B');
      expect(identity.set(p, p2), equals(p2));
    });

    test('Iso.compound with Lens returns a Lens and works', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();
      final lens = identity.compoundLens(PersonOptics.address);

      final p = ApiPerson(
        name: 'A',
        address: Address(streetName: 'X'),
      );

      expect(lens.get(p), equals(Address(streetName: 'X')));

      final p2 = lens.set(p, Address(streetName: 'Y'));
      expect(p2.address.streetName, equals('Y'));
    });

    test('Iso.compound with Prism returns a Prism and works', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();
      final prism = identity.compoundPrism(PersonOptics.job);

      var p = ApiPerson(
        name: 'A',
        address: Address(streetName: 'X'),
        job: Job(
          address: Address(streetName: 'HQ'),
          title: 'Dev',
        ),
      );

      expect(prism.get(p), equals(p.job));

      // Set to null through the Prism should clear the job.
      p = prism.set(p, null);
      expect(p.job, isNull);
    });

    test('Iso compound with different optic types', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();

      // Test compound with a simple lens
      final addressLens = identity.compoundLens(PersonOptics.address);

      final p = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
      );

      expect(addressLens.get(p), Address(streetName: 'Main St'));

      final p2 = addressLens.set(p, Address(streetName: 'Oak St'));
      expect(p2.address.streetName, 'Oak St');
    });

    test('ObjectIso extension asIso', () {
      final person = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
      );

      final iso = person.asIso();

      expect(iso.get(person), equals(person));

      final newPerson = person.copyWith(name: 'Jane');
      expect(iso.set(person, newPerson), equals(newPerson));
    });

    test('Instance jobOptic using asIso compound', () {
      final person = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
        job: Job(
          title: 'Developer',
          address: Address(streetName: 'HQ'),
        ),
      );

      final jobOptic = person.jobOptic;

      expect(jobOptic.get(person), equals(person.job));

      final updatedPerson = jobOptic.set(person, null);
      expect(updatedPerson.job, isNull);
    });

    test('Iso type guard behavior', () {
      const identity = Iso<Zoo, Zoo>.identity();

      final zoo = Zoo(const Cat('Whiskers'));
      final lens = identity.compoundLens(zooAnimal);

      expect(lens.get(zoo), isA<Cat>());
      expect((lens.get(zoo) as Cat).name, 'Whiskers');

      final newZoo = lens.set(zoo, Dog('Rover'));
      expect((newZoo.animal as Dog).name, 'Rover');
    });

    test('utf8Iso round-trips between String and code units', () {
      const word = 'hello';

      expect(utf8Iso.get(word), equals([104, 101, 108, 108, 111]));

      final encoded = 'wave'.codeUnits;
      expect(utf8Iso.set('', encoded), equals('wave'));

      // Ensure original source value is ignored
      expect(utf8Iso.set(word, encoded), equals('wave'));
    });
  });
}
