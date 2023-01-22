import 'package:meta/meta.dart';
import 'package:optics/optics.dart';

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

extension PersonOptics on Person {
  static final Lens<Person, Address> address = Lens(
    getter: (subject) => subject.address,
    setter: (subject, value) => subject.copyWith(address: value),
  );

  static final Lens<Person, String> addressName =
      address.compound(AddressOptics.streetName);

  static final Prism<Person, Job?> job = Prism(
    getter: (subject) => subject.job,
    setter: (subject, value) => subject.copyWith(job: value),
  );

  static final Prism<Person, String?> jobTitle =
      job.compound(JobOptics.title.asPrism());

  static final Prism<Person, String?> jobAddressName = Prism.join(
    sourcePrism: Prism.join(
      sourcePrism: job,
      throughPrism: JobOptics.address.asPrism(),
    ),
    throughPrism: AddressOptics.streetName.asPrism(),
  );

  BoundLens<Person, Address> get addressOptic =>
      BoundLens(source: this, lens: address);

  BoundPrism<Person, Job?> get jobOptic => BoundPrism(source: this, prism: job);
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

extension AddressOptics on Address {
  static final Lens<Address, String> streetName = Lens(
    getter: (subject) {
      return subject.streetName;
    },
    setter: (subject, value) {
      return subject.copyWith(streetName: value);
    },
  );

  BoundLens<Address, String> get streetNameOptic =>
      BoundLens(source: this, lens: streetName);
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

extension JobOptics on Job {
  static final Lens<Job, String> title = Lens(
    getter: (subject) {
      return subject.title;
    },
    setter: (subject, value) {
      return subject.copyWith(title: value);
    },
  );

  static final Lens<Job, Address> address = Lens(
    getter: (subject) {
      return subject.address;
    },
    setter: (subject, value) {
      return subject.copyWith(address: value);
    },
  );

  BoundLens<Job, String> get titleOptic => BoundLens(source: this, lens: title);

  BoundLens<Job, Address> get addressOptic =>
      BoundLens(source: this, lens: address);
}

extension StringOptics on String {
  BoundLens<String, String> get indefiniteArticle => BoundLens(
        source: this,
        lens: Lens(
          getter: (source) {
            if (source.isEmpty) {
              return source;
            }

            final vowels = ['a', 'e', 'i', 'o', 'u'];

            for (final vowel in vowels) {
              if (source.toLowerCase().startsWith(vowel)) {
                return 'an';
              }
            }

            return 'a';
          },
          setter: (source, value) => value,
        ),
      );
}

class Nullable {
  const Nullable();
  static const instance = Nullable();
}
