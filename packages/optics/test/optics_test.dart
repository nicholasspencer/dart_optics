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
    test('view', () {
      expect(
        subject?.addressLens.view?.call(subject),
        equals(Address(streetName: '123 Capital of Texas Hwy')),
      );

      expect(
        subject?.jobLens.view?.call(subject),
        isNull,
      );

      subject = subject?.jobLens.mutate?.call(
        subject,
        Job(
          address: Address(
            streetName: '456 Mesa Dr',
          ),
        ),
      );

      expect(
        subject?.jobLens.view?.call(subject),
        Job(
          address: Address(
            streetName: '456 Mesa Dr',
          ),
        ),
      );

      expect(
        subject?.jobAddressNameLens.view?.call(subject),
        '456 Mesa Dr',
      );
    });

    test('mutate', () {
      subject = subject?.addressLens.mutate?.call(
        subject,
        Address(streetName: '789 Mopac Expy'),
      );

      expect(
        subject?.address,
        equals(Address(streetName: '789 Mopac Expy')),
      );

      subject = subject?.jobLens.mutate?.call(
        subject,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      expect(
        subject?.job,
        Job(
          address: Address(streetName: '123 Capital of Texas Hwy'),
          title: 'Software Engineer',
        ),
      );

      subject = subject?.jobAddressNameLens.mutate?.call(
        subject,
        '124 Research Blvd',
      );

      expect(
        subject?.jobAddressNameLens.view?.call(subject),
        '124 Research Blvd',
      );
    });
  });
}

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

  Lens<Person?, String?> get nameLens => Lens(
        accessor: (subject) => subject?.name,
        mutator: (subject, value) => subject?.copyWith(name: value),
      );

  Lens<Person?, Address?> get addressLens => Lens(
        accessor: (subject) => subject?.address,
        mutator: (subject, value) => subject?.copyWith(address: value),
      );

  Lens<Person?, String?> get addressNameLens =>
      addressLens.compoundWithFocusFactory(
        (address) => address?.streetNameLens,
      );

  Lens<Person?, Job?> get jobLens => Lens(
        accessor: (subject) => subject?.job,
        mutator: (subject, value) => subject?.copyWith(job: value),
      );

  Lens<Person?, String?> get jobTitleLens => jobLens.compoundWithFocusFactory(
        (job) => job?.titleLens,
      );

  Lens<Person?, String?> get jobAddressNameLens =>
      jobLens.compoundWithFocusFactory((job) {
        return job?.addressLens;
      }).compoundWithFocusFactory((address) {
        return address?.streetNameLens;
      });

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

  Lens<Address?, String?> get streetNameLens => Lens(
        accessor: (subject) {
          return subject?.streetName;
        },
        mutator: (subject, value) {
          return subject?.copyWith(streetName: value);
        },
      );

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

  Lens<Job?, String?> get titleLens => Lens(
        accessor: (subject) => subject?.title,
        mutator: (subject, value) {
          return subject?.copyWith(title: value);
        },
      );

  Lens<Job?, Address?> get addressLens => Lens(
        accessor: (subject) {
          return subject?.address;
        },
        mutator: (subject, value) {
          return subject?.copyWith(address: value);
        },
      );

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
