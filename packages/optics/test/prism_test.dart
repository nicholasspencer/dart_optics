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

  group('Prism', () {
    test('getter', () {
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
    });

    test('get', () {
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
    });

    test('setter', () {
      var newSubject = PersonOptics.job.setter(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        newSubject.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      // Setting to null should clear the job
      newSubject = PersonOptics.job.setter(subject, null);
      expect(newSubject.job, isNull);
    });

    test('set', () {
      var newSubject = PersonOptics.job.set(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        newSubject.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      // Setting to null should clear the job
      newSubject = PersonOptics.job.set(subject, null);
      expect(newSubject.job, isNull);
    });

    test('compound with Lens creates AffineTraversal', () {
      final jobTitle = PersonOptics.job.compound(JobOptics.title);

      expect(jobTitle.get(subject), 'Sandwich Artist');

      var newSubject = jobTitle.set(subject, 'Senior Developer');
      expect(newSubject.job?.title, 'Senior Developer');

      // Test with null job
      final personWithoutJob = Person(
        name: 'Jane',
        address: Address(streetName: 'Main St'),
        job: null,
      );

      expect(jobTitle.get(personWithoutJob), isNull);

      // Setting when job is null should be no-op
      final unchanged = jobTitle.set(personWithoutJob, 'Manager');
      expect(unchanged.job, isNull);
    });

    test('Null propagation when source Focus is absent', () {
      final personWithoutJob = Person(
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

    test('compound Prism -> Prism with Zoo example', () {
      // Create a prism that extracts a Cat from Zoo if it's actually a Cat
      final catPrism = zooAnimal.asPrism().compound<Cat, String>(catName);

      final zooWithCat = Zoo(const Cat('Whiskers'));
      final zooWithDog = Zoo(Dog('Rover'));

      expect(catPrism.get(zooWithCat), 'Whiskers');
      expect(catPrism.get(zooWithDog), isNull);

      final updatedZoo = catPrism.set(zooWithCat, 'Mittens');
      expect((updatedZoo.animal as Cat).name, 'Mittens');

      // Setting on wrong type should be no-op
      final unchangedZoo = catPrism.set(zooWithDog, 'Felix');
      expect((unchangedZoo.animal as Dog).name, 'Rover');
    });
  });
}
