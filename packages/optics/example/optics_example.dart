import 'package:meta/meta.dart';
import 'package:optics/optics.dart';

void main() {
  Person person = Person(
    name: 'Joe',
    address: Address(streetName: '123 Capital of Texas Hwy'),
  );

  assert(person.address.streetName == '123 Capital of Texas Hwy');

  /// Joe moved!
  person = person.streetName.set('456 Mesa Dr');

  assert(person.address.streetName == '456 Mesa Dr');

  /// Joe got a job!
  person = BoundPrism(source: person, prism: PersonOptics.job).set(
    Job(address: Address(streetName: '789 E 6th St'), title: 'Sales bro'),
  );

  assert(person.job?.title == 'Sales bro');

  /// Joe got a promotion!
  person = person.jobTitle.set('Executive sales bro');

  assert(person.job?.title == 'Executive sales bro');

  print('''Howdy, ${person.name}!
You're ${person.jobTitle()?.indefiniteArticle()} ${person.jobTitle()}.
Nice place you've got @ ${person.streetName()}.''');
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

  BoundLens<Person, String> get streetName =>
      BoundLens(source: this, lens: PersonOptics.addressName);

  BoundPrism<Person, String?> get jobTitle =>
      BoundPrism(source: this, prism: PersonOptics.jobTitle);

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

class PersonOptics {
  static final Lens<Person, Address> address = Lens(
    getter: (subject) => subject.address,
    setter: (subject, value) => subject.copyWith(address: value),
  );

  static final Lens<Person, String> addressName =
      address.compoundWithOptical(AddressOptics.streetName);

  static final Prism<Person, Job?> job = Prism(
    getter: (subject) => subject.job,
    setter: (subject, value) => subject.copyWith(job: value),
  );

  static final Prism<Person, String?> jobTitle =
      job.compoundWithOptical(JobOptics.title.asPrism());

  static final Prism<Person, String?> jobAddressName = Prism.compound(
    sourcePrism: Prism.compound(
      sourcePrism: job,
      throughPrism: JobOptics.address.asPrism(),
    ),
    throughPrism: AddressOptics.streetName.asPrism(),
  );
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

class AddressOptics {
  static final Lens<Address, String> streetName = Lens(
    getter: (subject) {
      return subject.streetName;
    },
    setter: (subject, value) {
      return subject.copyWith(streetName: value);
    },
  );
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

class JobOptics {
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
