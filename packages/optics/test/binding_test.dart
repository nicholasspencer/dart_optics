import 'package:optics/optics.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('SourceBinding', () {
    test('call and set for Lens binding', () {
      final p = ApiPerson(
        name: 'John',
        address: Address(streetName: 'A'),
      );

      final binding = SourceBinding(source: p, optic: PersonOptics.address);
      expect(binding(), equals(Address(streetName: 'A')));

      final p2 = binding.set(Address(streetName: 'B'));
      expect(p2.address.streetName, equals('B'));
    });

    test('compound through Lens -> nullable Resolution', () {
      final p = ApiPerson(
        name: 'John',
        address: Address(streetName: 'A'),
      );

      final binding = SourceBinding(
        source: p,
        optic: PersonOptics.address,
      ).compound(AddressOptics.streetName);

      expect(binding(), equals('A'));

      final p2 = binding.set('B'); // setting non-null should update
      expect(p2.address.streetName, equals('B'));

      final p3 = binding.set(
        null,
      ); // null for non-nullable final lens is a no-op
      expect(p3.address.streetName, equals('A'));
    });

    test('compound Prism -> Lens (title), get and set', () {
      var p = ApiPerson(
        name: 'John',
        address: Address(streetName: 'A'),
        job: Job(
          title: 'Artist',
          address: Address(streetName: 'HQ'),
        ),
      );

      final binding = SourceBinding(
        source: p,
        optic: PersonOptics.job,
      ).compound(JobOptics.title);

      expect(binding(), equals('Artist'));

      final newP = binding.set('Senior Artist');
      expect(newP.job?.title, equals('Senior Artist'));

      // If job is absent, set should be a no-op
      final pWithoutJob = p.copyWith(job: null);
      final bindingWithoutJob = SourceBinding(
        source: pWithoutJob,
        optic: PersonOptics.job,
      ).compound(JobOptics.title);

      final p2 = bindingWithoutJob.set('Principal Artist');
      expect(p2.job, isNull);
    });

    test('instance addressOptic works', () {
      final person = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
      );

      final addressOptic = person.addressOptic;
      expect(addressOptic(), Address(streetName: 'Main St'));

      final updatedPerson = addressOptic.set(Address(streetName: 'Oak St'));
      expect(updatedPerson.address.streetName, 'Oak St');
    });

    test('instance jobOptic works', () {
      final person = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
        job: Job(
          title: 'Developer',
          address: Address(streetName: 'HQ'),
        ),
      );

      final jobOptic = person.jobOptic;
      expect(jobOptic.get(person), person.job);

      final updatedPerson = jobOptic.set(person, null);
      expect(updatedPerson.job, isNull);
    });

    test('Address streetNameOptic works', () {
      final address = Address(streetName: 'Main St');

      final streetOptic = address.streetNameOptic;
      expect(streetOptic(), 'Main St');

      final updatedAddress = streetOptic.set('Oak St');
      expect(updatedAddress.streetName, 'Oak St');
    });

    test('Job titleOptic and addressOptic work', () {
      final job = Job(
        title: 'Developer',
        address: Address(streetName: 'HQ St'),
      );

      final titleOptic = job.titleOptic;
      expect(titleOptic(), 'Developer');

      final updatedJob = titleOptic.set('Senior Developer');
      expect(updatedJob.title, 'Senior Developer');

      final addressOptic = job.addressOptic;
      expect(addressOptic(), Address(streetName: 'HQ St'));

      final jobWithNewAddress = addressOptic.set(Address(streetName: 'New HQ'));
      expect(jobWithNewAddress.address.streetName, 'New HQ');
    });

    test('compound binding with nullable final focus', () {
      final person = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
        job: Job(
          title: 'Developer',
          address: Address(streetName: 'HQ', buildingName: 'Tower A'),
        ),
      );

      final buildingBinding = SourceBinding(
        source: person,
        optic: PersonOptics.job,
      ).compound(JobOptics.address).compound(AddressOptics.buildingName);

      expect(buildingBinding(), 'Tower A');

      final updatedPerson = buildingBinding.set('Tower B');
      expect(updatedPerson.job?.address.buildingName, 'Tower B');

      // Setting null should work for nullable focus
      final clearedPerson = buildingBinding.set(null);
      expect(clearedPerson.job?.address.buildingName, isNull);
    });

    test('compound binding chains preserve source immutability', () {
      final originalPerson = ApiPerson(
        name: 'John',
        address: Address(streetName: 'Main St'),
        job: Job(
          title: 'Dev',
          address: Address(streetName: 'HQ'),
        ),
      );

      final titleBinding = SourceBinding(
        source: originalPerson,
        optic: PersonOptics.job,
      ).compound(JobOptics.title);

      final modifiedPerson = titleBinding.set('Senior Dev');

      // Original should be unchanged
      expect(originalPerson.job?.title, 'Dev');
      expect(modifiedPerson.job?.title, 'Senior Dev');
      expect(modifiedPerson.name, originalPerson.name);
      expect(modifiedPerson.address, originalPerson.address);
    });

    test('bind creates new binding with different source', () {
      final person1 = ApiPerson(
        name: 'Alice',
        address: Address(streetName: 'First St'),
      );

      final person2 = ApiPerson(
        name: 'Bob',
        address: Address(streetName: 'Second St'),
      );

      // Create binding with person1
      final addressBinding1 = SourceBinding(
        source: person1,
        optic: PersonOptics.address,
      );

      expect(addressBinding1(), Address(streetName: 'First St'));

      // Bind to person2 using same optic
      final addressBinding2 = addressBinding1.bind(person2);

      expect(addressBinding2(), Address(streetName: 'Second St'));

      // Original binding still works with original source
      expect(addressBinding1(), Address(streetName: 'First St'));

      // Both bindings use same optic but different sources
      expect(addressBinding1.optic, same(addressBinding2.optic));
      expect(addressBinding1.source, person1);
      expect(addressBinding2.source, person2);

      // Set operations work independently
      final updated1 = addressBinding1.set(Address(streetName: 'New First St'));
      final updated2 = addressBinding2.set(
        Address(streetName: 'New Second St'),
      );

      expect(updated1.address.streetName, 'New First St');
      expect(updated2.address.streetName, 'New Second St');
      expect(updated1.name, 'Alice');
      expect(updated2.name, 'Bob');
    });

    test('bind with compound binding preserves compound behavior', () {
      final person1 = ApiPerson(
        name: 'Alice',
        address: Address(streetName: 'First St'),
      );

      final person2 = ApiPerson(
        name: 'Bob',
        address: Address(streetName: 'Second St'),
      );

      // Create compound binding with person1
      final streetBinding1 = SourceBinding(
        source: person1,
        optic: PersonOptics.address,
      ).compound(AddressOptics.streetName);

      expect(streetBinding1(), 'First St');

      // Bind to person2
      final streetBinding2 = streetBinding1.bind(person2);

      expect(streetBinding2(), 'Second St');

      // Set through compound binding
      final updated1 = streetBinding1.set('Updated First St');
      final updated2 = streetBinding2.set('Updated Second St');

      expect(updated1.address.streetName, 'Updated First St');
      expect(updated2.address.streetName, 'Updated Second St');
      expect(updated1.name, 'Alice');
      expect(updated2.name, 'Bob');
    });
  });
}
