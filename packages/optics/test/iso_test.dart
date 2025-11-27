import 'package:optics/optics.dart';
import 'package:test/test.dart';

import 'test_models.dart';

void main() {
  group('Iso', () {
    test('to', () {
      final apiToDomain = Iso<ApiPerson, DomainPerson>(
        to: (source) => DomainPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => ApiPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final apiPerson = ApiPerson(
        name: 'Alice',
        address: Address(streetName: '123 Main St', buildingName: 'Apt 4'),
        job: Job(
          address: Address(streetName: '456 Work Rd', buildingName: 'Suite 1'),
          title: 'Engineer',
        ),
      );

      final domainPerson = apiToDomain.get(apiPerson);

      expect(domainPerson.name, equals('Alice'));
      expect(domainPerson.address.streetName, equals('123 Main St'));
      expect(domainPerson.address.buildingName, equals('Apt 4'));
      expect(domainPerson.job!.title, equals('Engineer'));
      expect(domainPerson.job!.address.streetName, equals('456 Work Rd'));

      final updatedApiPerson = apiToDomain.set(
        apiPerson,
        domainPerson.copyWith(name: 'Bob'),
      );

      expect(updatedApiPerson.name, equals('Bob'));
      expect(updatedApiPerson.address.streetName, equals('123 Main St'));
    });

    test('from', () {
      final domainToApi = Iso<DomainPerson, ApiPerson>(
        to: (source) => ApiPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => DomainPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final domainPerson = DomainPerson(
        name: 'Charlie',
        address: Address(streetName: '789 Side St', buildingName: 'Unit B'),
      );

      final apiPerson = domainToApi.get(domainPerson);

      expect(apiPerson.name, equals('Charlie'));
      expect(apiPerson.address.streetName, equals('789 Side St'));
      expect(apiPerson.address.buildingName, equals('Unit B'));

      final updatedDomainPerson = domainToApi.set(
        domainPerson,
        apiPerson.copyWith(name: 'Dana'),
      );

      expect(updatedDomainPerson.name, equals('Dana'));
      expect(updatedDomainPerson.address.streetName, equals('789 Side St'));
    });
  });

  group('Iso.identity', () {
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

  group('Iso laws', () {
    test('apiToDomain Iso left/right inverse laws', () {
      final apiToDomain = Iso<ApiPerson, DomainPerson>(
        to: (source) => DomainPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => ApiPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final apiPerson = ApiPerson(
        name: 'Alice',
        address: Address(streetName: '123 Main St', buildingName: 'Apt 4'),
        job: Job(
          address: Address(streetName: '456 Work Rd', buildingName: 'Suite 1'),
          title: 'Engineer',
        ),
      );

      // Law: set(s, get(s)) == s
      expect(
        apiToDomain.set(apiPerson, apiToDomain.get(apiPerson)),
        equals(apiPerson),
      );

      // Law: get(set(s, f)) == f
      final domainFocus = DomainPerson(
        name: 'Bob',
        address: Address(streetName: '789 Side St', buildingName: 'Unit B'),
        job: Job(
          title: 'Architect',
          address: Address(streetName: 'HQ', buildingName: 'Tower'),
        ),
      );
      expect(
        apiToDomain.get(apiToDomain.set(apiPerson, domainFocus)),
        equals(domainFocus),
      );
    });

    test('domainToApi Iso left/right inverse laws', () {
      final domainToApi = Iso<DomainPerson, ApiPerson>(
        to: (source) => ApiPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => DomainPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final domainPerson = DomainPerson(
        name: 'Charlie',
        address: Address(streetName: '789 Side St', buildingName: 'Unit B'),
        job: Job(
          title: 'Designer',
          address: Address(streetName: 'Design HQ', buildingName: 'Studio'),
        ),
      );

      // Law: set(s, get(s)) == s
      expect(
        domainToApi.set(domainPerson, domainToApi.get(domainPerson)),
        equals(domainPerson),
      );

      // Law: get(set(s, f)) == f
      final apiFocus = ApiPerson(
        name: 'Dana',
        address: Address(streetName: '321 Return Rd', buildingName: 'Annex'),
        job: Job(
          title: 'Manager',
          address: Address(streetName: 'Ops', buildingName: 'Floor 2'),
        ),
      );
      expect(
        domainToApi.get(domainToApi.set(domainPerson, apiFocus)),
        equals(apiFocus),
      );
    });

    test('apiToDomain and domainToApi composition behaves like identity', () {
      final apiToDomain = Iso<ApiPerson, DomainPerson>(
        to: (source) => DomainPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => ApiPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final domainToApi = Iso<DomainPerson, ApiPerson>(
        to: (source) => ApiPerson(
          name: source.name,
          address: Address(
            streetName: source.address.streetName,
            buildingName: source.address.buildingName,
          ),
          job: source.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: source.job!.address.streetName,
                    buildingName: source.job!.address.buildingName,
                  ),
                  title: source.job!.title,
                ),
        ),
        from: (source, value) => DomainPerson(
          name: value.name,
          address: Address(
            streetName: value.address.streetName,
            buildingName: value.address.buildingName,
          ),
          job: value.job == null
              ? null
              : Job(
                  address: Address(
                    streetName: value.job!.address.streetName,
                    buildingName: value.job!.address.buildingName,
                  ),
                  title: value.job!.title,
                ),
        ),
      );

      final apiPerson = ApiPerson(
        name: 'Alice',
        address: Address(streetName: '123 Main St', buildingName: 'Apt 4'),
        job: Job(
          address: Address(streetName: '456 Work Rd', buildingName: 'Suite 1'),
          title: 'Engineer',
        ),
      );
      final domainPerson = apiToDomain.get(apiPerson);

      // Forward then backward
      expect(domainToApi.get(domainPerson), equals(apiPerson));
      // Backward then forward
      expect(
        apiToDomain.get(domainToApi.get(domainPerson)),
        equals(domainPerson),
      );
    });

    test('utf8Iso law tests and edge cases', () {
      const samples = ['', 'hello', '👋🌍'];
      for (final s in samples) {
        // set(s, get(s)) == s
        expect(utf8Iso.set(s, utf8Iso.get(s)), equals(s));
        // get(set(any, get(s))) == get(s) (source ignored)
        expect(
          utf8Iso.get(utf8Iso.set('ignored', utf8Iso.get(s))),
          equals(utf8Iso.get(s)),
        );
      }

      // Arbitrary code units list
      final units = 'wave'.codeUnits;
      expect(utf8Iso.get(utf8Iso.set('', units)), equals(units));

      // Emoji stability
      final emojiUnits = '👋'.codeUnits;
      expect(
        utf8Iso.get(utf8Iso.set('baseline', emojiUnits)),
        equals(emojiUnits),
      );

      // Setter ignores original source baseline
      expect(utf8Iso.set('original', 'data'.codeUnits), equals('data'));
    });
  });

  group('Mixed Prism/Lens chains', () {
    test(
      'Iso -> Prism(job) -> Lens(title) chain get/set and null propagation',
      () {
        const identity = Iso<ApiPerson, ApiPerson>.identity();
        final jobTitle = identity
            .compoundPrism(PersonOptics.job)
            .compound(
              JobOptics.title,
            ); // Prism then Lens becomes AffineTraversal

        final withJob = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Main'),
          job: Job(
            title: 'Developer',
            address: Address(streetName: 'HQ'),
          ),
        );

        // Get title when job exists
        expect(jobTitle.get(withJob), equals('Developer'));

        // Update title through chain
        final updated = jobTitle.set(withJob, 'Lead Dev');
        expect(updated.job!.title, equals('Lead Dev'));

        // Person with null job returns null focus
        final withoutJob = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Main'),
          job: null,
        );
        expect(jobTitle.get(withoutJob), isNull);

        // Setting via chain when intermediate (job) is null should no-op
        final stillWithoutJob = jobTitle.set(withoutJob, 'Anything');
        expect(stillWithoutJob.job, isNull);
      },
    );

    test(
      'Iso -> Prism(job) -> Lens(address) -> Lens(streetName) deep chain',
      () {
        const identity = Iso<ApiPerson, ApiPerson>.identity();
        final jobStreet = identity
            .compoundPrism(PersonOptics.job)
            .compound(JobOptics.address)
            .compound(AddressOptics.streetName); // AffineTraversal to String

        final withJob = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Home'),
          job: Job(
            title: 'Developer',
            address: Address(streetName: 'Office'),
          ),
        );

        expect(jobStreet.get(withJob), equals('Office'));

        final updated = jobStreet.set(withJob, 'Remote');
        expect(updated.job!.address.streetName, equals('Remote'));

        // Null intermediate short-circuits
        final withoutJob = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Home'),
          job: null,
        );
        expect(jobStreet.get(withoutJob), isNull);
        final unchanged = jobStreet.set(withoutJob, 'Ignored');
        expect(unchanged.job, isNull);
      },
    );

    test(
      'Iso -> Prism(job) -> Lens(address) -> Lens(buildingName) nullable final focus',
      () {
        const identity = Iso<ApiPerson, ApiPerson>.identity();
        final buildingTraversal = identity
            .compoundPrism(PersonOptics.job)
            .compound(JobOptics.address)
            .compound(AddressOptics.buildingName); // Nullable final resolution

        final withBuilding = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Home'),
          job: Job(
            title: 'Developer',
            address: Address(streetName: 'Office', buildingName: 'Tower'),
          ),
        );

        expect(buildingTraversal.get(withBuilding), equals('Tower'));

        final updated = buildingTraversal.set(withBuilding, 'Annex');
        expect(updated.job!.address.buildingName, equals('Annex'));

        // Set final nullable focus to null
        final cleared = buildingTraversal.set(updated, null);
        expect(cleared.job!.address.buildingName, isNull);

        // Null intermediate job
        final withoutJob = ApiPerson(
          name: 'Dev',
          address: Address(streetName: 'Home'),
          job: null,
        );
        expect(buildingTraversal.get(withoutJob), isNull);
        final stillWithout = buildingTraversal.set(withoutJob, 'Ignored');
        expect(stillWithout.job, isNull);
      },
    );
  });
  group('Deep Lens chains', () {
    test('Iso -> Lens(address) -> Lens(streetName) strong lens chain', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();
      final streetLens = identity
          .compoundLens(PersonOptics.address)
          .compound(AddressOptics.streetName);

      final person = ApiPerson(
        name: 'Alex',
        address: Address(streetName: 'Old Rd'),
      );

      // Type remains Lens and focus is String
      expect(streetLens, isA<Lens<ApiPerson, String>>());
      expect(streetLens.get(person), equals('Old Rd'));

      final updated = streetLens.set(person, 'New Ave');
      expect(updated.address.streetName, equals('New Ave'));
      // Ensure other fields unchanged
      expect(updated.name, equals('Alex'));
    });

    test('Iso -> Lens(address) -> Lens(buildingName) nullable focus chain', () {
      const identity = Iso<ApiPerson, ApiPerson>.identity();
      final buildingLens = identity
          .compoundLens(PersonOptics.address)
          .compound(AddressOptics.buildingName); // Lens with nullable focus

      final person = ApiPerson(
        name: 'Bea',
        address: Address(streetName: 'Central', buildingName: 'Block A'),
      );

      expect(buildingLens.get(person), equals('Block A'));
      final cleared = buildingLens.set(person, null);
      expect(cleared.address.buildingName, isNull);

      final restored = buildingLens.set(cleared, 'Block B');
      expect(restored.address.buildingName, equals('Block B'));
    });

    test(
      'Iso -> Lens(address) -> Lens(streetName) -> Lens(custom length) deep chain',
      () {
        const identity = Iso<ApiPerson, ApiPerson>.identity();
        // Custom lens from String -> int (length) losing information intentionally for composition test
        final lengthLens = Lens<String, int>(
          getter: (s) => s.length,
          setter: (s, len) =>
              'x' * len, // produce placeholder string of desired length
        );

        final lengthChain = identity
            .compoundLens(PersonOptics.address)
            .compound(AddressOptics.streetName)
            .compound(lengthLens); // Still a Lens<ApiPerson, int>

        final person = ApiPerson(
          name: 'Cara',
          address: Address(streetName: 'Alpine'), // length 6
        );

        expect(lengthChain.get(person), equals(6));

        final updated = lengthChain.set(person, 3);
        expect(updated.address.streetName, equals('xxx'));
        // Changing length again
        final updated2 = lengthChain.set(updated, 5);
        expect(updated2.address.streetName, equals('xxxxx'));

        // Lens type preserved across 3 lens compositions
        expect(lengthChain, isA<Lens<ApiPerson, int>>());
      },
    );
  });

  group('Type guard and mismatch tests', () {
    test('Iso compoundLens type mismatch returns original source on set', () {
      const identity = Iso<Zoo, Zoo>.identity();

      // Create a lens that expects Cat but zoo might have Dog
      final catNameLens = Lens<Animal, String>(
        getter: (a) {
          if (a is Cat) return a.name;
          throw ArgumentError('Expected Cat but got ${a.runtimeType}');
        },
        setter: (a, name) {
          if (a is Cat) return Cat(name);
          return a; // Return original if not Cat
        },
      );

      final zooWithCat = Zoo(const Cat('Whiskers'));
      final zooWithDog = Zoo(const Dog('Rover'));

      // Compound zooAnimal lens with cat-specific lens
      final catChain = identity.compoundLens(zooAnimal).compound(catNameLens);

      // Works fine with Cat
      expect(catChain.get(zooWithCat), equals('Whiskers'));
      final updatedCat = catChain.set(zooWithCat, 'Mittens');
      expect((updatedCat.animal as Cat).name, equals('Mittens'));

      // Type mismatch: Dog instead of Cat throws on get
      expect(() => catChain.get(zooWithDog), throwsArgumentError);

      // Set on mismatched type returns original (because intermediate doesn't match expected type)
      final unchanged = catChain.set(zooWithDog, 'IgnoredName');
      expect((unchanged.animal as Dog).name, equals('Rover'));
    });

    test(
      'Iso compoundPrism with null intermediate short-circuits gracefully',
      () {
        const identity = Iso<ApiPerson, ApiPerson>.identity();
        final jobPrism = identity.compoundPrism(PersonOptics.job);

        final withoutJob = ApiPerson(
          name: 'Jobless',
          address: Address(streetName: 'Home St'),
        );

        // Get returns null for missing job
        expect(jobPrism.get(withoutJob), isNull);

        // Set with null clears job (no-op when already null)
        final stillNull = jobPrism.set(withoutJob, null);
        expect(stillNull.job, isNull);

        // Set with non-null value sets the job
        final withJob = jobPrism.set(
          withoutJob,
          Job(
            title: 'Developer',
            address: Address(streetName: 'Office'),
          ),
        );
        expect(withJob.job, isNotNull);
        expect(withJob.job!.title, equals('Developer'));
      },
    );
  });

  group('SourceBinding chain tests', () {
    test('SourceBinding with Iso.identity compound preserves immutability', () {
      final person = ApiPerson(
        name: 'Original',
        address: Address(streetName: 'First St'),
      );

      const identity = Iso<ApiPerson, ApiPerson>.identity();
      final binding = SourceBinding(source: person, optic: identity);

      // Get via binding
      expect(binding(), equals(person));

      // Set via binding returns new instance
      final newPerson = person.copyWith(name: 'Updated');
      final updatedBinding = binding.set(newPerson);
      expect(updatedBinding, equals(newPerson));
      expect(person.name, equals('Original')); // Original unchanged
    });

    test('SourceBinding compound with Lens then update', () {
      final person = ApiPerson(
        name: 'Dev',
        address: Address(streetName: 'Main St'),
      );

      final addressBinding = SourceBinding(
        source: person,
        optic: PersonOptics.address,
      );

      // Get address
      expect(addressBinding().streetName, equals('Main St'));

      // Set address
      final newAddress = Address(streetName: 'Oak Ave', buildingName: 'Tower');
      final updated = addressBinding.set(newAddress);
      expect(updated.address.streetName, equals('Oak Ave'));
      expect(updated.address.buildingName, equals('Tower'));
      expect(
        person.address.streetName,
        equals('Main St'),
      ); // Original unchanged
    });

    test('SourceBinding compound Prism chain with nullable resolution', () {
      final withJob = ApiPerson(
        name: 'Employee',
        address: Address(streetName: 'Home'),
        job: Job(
          title: 'Engineer',
          address: Address(streetName: 'Office'),
        ),
      );

      final jobBinding = withJob.jobBinding;

      // Get job (non-null)
      expect(jobBinding(), equals(withJob.job));

      // Compound with title lens
      final titleChain = jobBinding.compound(JobOptics.title);
      expect(titleChain(), equals('Engineer'));

      // Update via chain
      final updated = titleChain.set('Senior Engineer');
      expect(updated.job!.title, equals('Senior Engineer'));

      // Test with person without job
      final withoutJob = ApiPerson(
        name: 'Unemployed',
        address: Address(streetName: 'Home'),
      );
      final nullJobBinding = withoutJob.jobBinding;
      expect(nullJobBinding(), isNull);

      final nullTitleChain = nullJobBinding.compound(JobOptics.title);
      expect(nullTitleChain(), isNull);

      // Setting on null chain returns original source unchanged
      final stillNull = nullTitleChain.set('Anything');
      expect(stillNull.job, isNull);
    });

    test(
      'SourceBinding bind updates source while preserving compound path',
      () {
        final person1 = ApiPerson(
          name: 'Alice',
          address: Address(streetName: 'First St'),
        );

        final person2 = ApiPerson(
          name: 'Bob',
          address: Address(streetName: 'Second St'),
        );

        final addressBinding = SourceBinding(
          source: person1,
          optic: PersonOptics.address,
        );

        expect(addressBinding().streetName, equals('First St'));

        // Bind to new source
        final rebound = addressBinding.bind(person2);
        expect(rebound().streetName, equals('Second St'));

        // Compound path works on rebound binding
        final streetBinding = rebound.compound(AddressOptics.streetName);
        expect(streetBinding(), equals('Second St'));

        final updated = streetBinding.set('Third Ave');
        expect(updated.address.streetName, equals('Third Ave'));
        expect(updated.name, equals('Bob')); // Name preserved from person2
      },
    );
  });
}
