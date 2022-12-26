import 'package:meta/meta.dart';
import 'package:optics/optics.dart';
import 'package:test/test.dart';

void main() {
  Person? subject;

  setUp(() {
    subject = Person(
      name: 'John',
      address: Address(
        streetName: '123 Capital of Texas Hwy',
      ),
    );
  });
  group('Lens', () {
    test('accessor', () {
      expect(
        personAddressLens.accessor?.call(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        personJobLens.accessor?.call(subject),
        isNull,
      );

      subject = personJobLens.mutator?.call(
        subject,
        Job(
          address: Address(
            streetName: '456 Mesa Dr',
          ),
        ),
      );

      expect(
        personJobLens.accessor?.call(subject),
        equals(
          Job(
            address: Address(
              streetName: '456 Mesa Dr',
            ),
          ),
        ),
      );

      expect(
        personJobAddressNameLens.accessor?.call(subject),
        '456 Mesa Dr',
      );
    });

    test('view', () {
      expect(
        personAddressLens.view(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        personJobLens.view(subject),
        isNull,
      );

      subject = personJobLens.mutate(
        subject,
        Job(
          address: Address(
            streetName: '456 Mesa Dr',
          ),
        ),
      );

      expect(
        personJobLens.view(subject),
        equals(
          Job(
            address: Address(
              streetName: '456 Mesa Dr',
            ),
          ),
        ),
      );

      expect(
        personJobAddressNameLens.view(subject),
        '456 Mesa Dr',
      );
    });

    test('mutator', () {
      subject = personAddressLens.mutator?.call(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject?.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

      subject = personJobLens.mutator?.call(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        subject?.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      subject = personJobAddressNameLens.mutator?.call(
        subject,
        '124 Research Blvd',
      );

      expect(
        personJobAddressNameLens.accessor?.call(subject),
        '124 Research Blvd',
      );
    });

    test('mutate', () {
      subject = personAddressLens.mutate(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject?.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

      subject = personJobLens.mutate(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        subject?.job,
        equals(
          Job(
            address: Address(streetName: '123 Capital of Texas Hwy'),
            title: 'Software Engineer',
          ),
        ),
      );

      subject = personJobAddressNameLens.mutate(
        subject,
        '124 Research Blvd',
      );

      expect(
        subject?.job?.address.streetName,
        equals('124 Research Blvd'),
      );
    });
  });
  group('BoundLens', () {
    test('call', () {
      expect(subject?.streetName(), equals('123 Capital of Texas Hwy'));
      expect(subject?.jobTitle(), isNull);
    });
    test('mutate', () {
      subject = subject?.streetName.mutate('789 Mopac Expy');
      expect(subject?.address.streetName, equals('789 Mopac Expy'));

      subject = subject?.copyWith(
        job: Job(
          address: Address(streetName: '124 Research Blvd'),
        ),
      );

      subject = subject?.jobTitle.mutate('Software Engineer');
      expect(subject?.job?.title, 'Software Engineer');
    });
  });
}

final Lens<Job?, String?> jobTitleLens = Lens(
  accessor: (subject) {
    return subject?.title;
  },
  mutator: (subject, value) {
    return subject?.copyWith(title: value);
  },
);

final Lens<Job?, Address?> jobAddressLens = Lens(
  accessor: (subject) {
    return subject?.address;
  },
  mutator: (subject, value) {
    return subject?.copyWith(address: value);
  },
);

final Lens<Address?, String?> addressStreetNameLens = Lens(
  accessor: (subject) {
    return subject?.streetName;
  },
  mutator: (subject, value) {
    return subject?.copyWith(streetName: value);
  },
);

final Lens<Person?, Address?> personAddressLens = Lens(
  accessor: (subject) => subject?.address,
  mutator: (subject, value) => subject?.copyWith(address: value),
);

final Lens<Person?, String?> personAddressNameLens =
    personAddressLens.compoundWithFocusFactory((address) {
  return addressStreetNameLens;
});

final Lens<Person?, Job?> personJobLens = Lens(
  accessor: (subject) => subject?.job,
  mutator: (subject, value) => subject?.copyWith(job: value),
);

final Lens<Person?, String?> personJobTitleLens =
    personJobLens.compoundWithFocusFactory((job) {
  return jobTitleLens;
});

final Lens<Person?, String?> personJobAddressNameLens =
    personJobLens.compoundWithFocusFactory((job) {
  return jobAddressLens;
}).compoundWithFocusFactory((address) {
  return addressStreetNameLens;
});

@immutable
class Person {
  const Person({
    required this.name,
    required this.address,
    this.job,
  });

  final String name;

  final Address address;

  final Job? job;

  BoundLens<Person, String> get streetName =>
      BoundLens(source: this, lens: personAddressNameLens);

  BoundLens<Person, String> get jobTitle =>
      BoundLens(source: this, lens: personJobTitleLens);

  Person copyWith({
    String? name,
    Address? address,
    Object? job = Nullable.instance,
  }) =>
      Person(
        name: name ?? this.name,
        address: address ?? this.address,
        job: job == Nullable.instance ? this.job : job as Job?,
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
    this.title,
  });

  final String? title;

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
