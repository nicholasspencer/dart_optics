import 'package:meta/meta.dart';
import 'package:optics/optics.dart';
import 'package:test/test.dart';

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

  group('Lens', () {
    test('getter', () {
      expect(
        personAddressLens.getter(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        personJobLens.getter(subject),
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
        personJobAddressNameLens.getter(subject),
        '456 Mesa Dr',
      );
    });

    test('view', () {
      expect(
        personAddressLens.get(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        personJobLens.get(subject),
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
        personJobAddressNameLens.get(subject),
        '456 Mesa Dr',
      );
    });

    test('setter', () {
      subject = personAddressLens.setter(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

      subject = personJobLens.setter(
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

      subject = personJobAddressNameLens.setter(
        subject,
        '124 Research Blvd',
      );

      expect(
        personJobAddressNameLens.getter(subject),
        '124 Research Blvd',
      );
    });

    test('mutate', () {
      subject = personAddressLens.set(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

      subject = personJobLens.set(
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

      subject = personJobAddressNameLens.set(
        subject,
        '124 Research Blvd',
      );

      expect(
        subject.job.address.streetName,
        equals('124 Research Blvd'),
      );
    });

    test('map', () {
      expect(
        personAddressNameLens
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
  group('BoundLens', () {
    test('call', () {
      expect(subject.streetName(), equals('123 Capital of Texas Hwy'));
      expect(subject.jobTitle(), 'Sandwich Artist');
    });

    test('mutate', () {
      subject = subject.streetName.set('789 Mopac Expy');
      expect(subject.address.streetName, equals('789 Mopac Expy'));

      subject = subject.jobTitle.set('Software Engineer');
      expect(subject.job.title, 'Software Engineer');
    });

    test('map', () {
      expect(
        subject.streetName
            .map(
              map: (focus) => focus.toUpperCase(),
            )
            .address
            .streetName,
        equals('123 CAPITAL OF TEXAS HWY'),
      );
    });
  });
}

final Lens<Job, String> jobTitleLens = Lens(
  getter: (subject) {
    return subject.title;
  },
  setter: (subject, value) {
    return subject.copyWith(title: value);
  },
);

final Lens<Job, Address> jobAddressLens = Lens(
  getter: (subject) {
    return subject.address;
  },
  setter: (subject, value) {
    return subject.copyWith(address: value);
  },
);

final Lens<Address, String> addressStreetNameLens = Lens(
  getter: (subject) {
    return subject.streetName;
  },
  setter: (subject, value) {
    return subject.copyWith(streetName: value);
  },
);

final Lens<Person, Address> personAddressLens = Lens(
  getter: (subject) => subject.address,
  setter: (subject, value) => subject.copyWith(address: value),
);

final Lens<Person, String> personAddressNameLens =
    personAddressLens.compoundWithOptic(addressStreetNameLens);

final Lens<Person, Job> personJobLens = Lens(
  getter: (subject) => subject.job,
  setter: (subject, value) => subject.copyWith(job: value),
);

final Lens<Person, String> personJobTitleLens =
    personJobLens.compoundWithOptic(jobTitleLens);

final Lens<Person, String> personJobAddressNameLens = personJobLens
    .compoundWithOptic<Address>(jobAddressLens)
    .compoundWithOptic(addressStreetNameLens);

@immutable
class Person {
  const Person({
    required this.name,
    required this.address,
    required this.job,
  });

  final String name;

  final Address address;

  final Job job;

  BoundLens<Person, String> get streetName =>
      BoundLens(source: this, lens: personAddressNameLens);

  BoundLens<Person, String> get jobTitle =>
      BoundLens(source: this, lens: personJobTitleLens);

  Person copyWith({
    String? name,
    Address? address,
    Job? job,
  }) =>
      Person(
        name: name ?? this.name,
        address: address ?? this.address,
        job: job ?? this.job,
      );

  @override
  bool operator ==(Object? other) =>
      identical(this, other) ||
      other is Person &&
          name == other.name &&
          address == other.address &&
          job == other.job;

  @override
  int get hashCode => Object.hash(name, address, job);
}

@immutable
class Address {
  const Address({required this.streetName});

  final String streetName;

  Address copyWith({String? streetName}) => Address(
        streetName: streetName ?? this.streetName,
      );

  @override
  bool operator ==(Object? other) =>
      identical(this, other) ||
      other is Address && streetName == other.streetName;

  @override
  int get hashCode => streetName.hashCode;
}

@immutable
class Job {
  Job({
    required this.address,
    required this.title,
  });

  final String title;

  final Address address;

  Job copyWith({String? title, Address? address}) => Job(
        title: title ?? this.title,
        address: address ?? this.address,
      );

  @override
  bool operator ==(Object? other) =>
      identical(this, other) ||
      other is Job && title == other.title && address == other.address;

  @override
  int get hashCode => Object.hash(title, address);
}

class Nullable {
  const Nullable();
  static const instance = Nullable();
}
