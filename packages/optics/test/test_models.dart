import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:optics/optics.dart';

part 'test_models.freezed.dart';

@freezed
abstract class ApiPerson with _$ApiPerson {
  const factory ApiPerson({
    required String name,
    required Address address,
    Job? job,
  }) = _ApiPerson;
}

@freezed
abstract class Address with _$Address {
  const factory Address({required String streetName, String? buildingName}) =
      _Address;
}

@freezed
abstract class Job with _$Job {
  const factory Job({required Address address, required String title}) = _Job;
}

extension PersonOptics on ApiPerson {
  static final Lens<ApiPerson, Address> address = Lens(
    getter: (subject) => subject.address,
    setter: (subject, value) => subject.copyWith(address: value),
  );

  static final Lens<ApiPerson, String> addressName = address.compound(
    AddressOptics.streetName,
  );

  static final Prism<ApiPerson, Job?> job = Prism(
    getter: (subject) => subject.job,
    setter: (subject, value) => subject.copyWith(job: value),
  );

  static final jobTitle = job.compound(JobOptics.title);

  static final jobAddressName = AffineTraversal(
    source: AffineTraversal(source: job, through: JobOptics.address),
    through: AddressOptics.streetName,
  );

  SourceBinding<ApiPerson, Address> get addressOptic =>
      SourceBinding(source: this, optic: address);

  Prism<ApiPerson, Job?> get jobOptic => asIso().compoundPrism(job);

  static final worksInBuildingName = AffineTraversal(
    source: AffineTraversal(source: job, through: JobOptics.address),
    through: AddressOptics.buildingName,
  );
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

  static final Lens<Address, String?> buildingName = Lens(
    getter: (subject) {
      return subject.buildingName;
    },
    setter: (subject, value) {
      return subject.copyWith(buildingName: value);
    },
  );

  SourceBinding<Address, String> get streetNameOptic =>
      SourceBinding(source: this, optic: streetName);
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

  SourceBinding<Job, String> get titleOptic =>
      SourceBinding(source: this, optic: title);

  SourceBinding<Job, Address> get addressOptic =>
      SourceBinding(source: this, optic: address);
}

extension StringOptics on String {
  SourceBinding<String, String> get indefiniteArticle => SourceBinding(
    source: this,
    optic: Lens(
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

// Test doubles for type guard testing
class Animal {
  final String name;
  const Animal(this.name);
}

class Cat extends Animal {
  const Cat(super.name);
}

class Dog extends Animal {
  const Dog(super.name);
}

class Zoo {
  final Animal animal;
  const Zoo(this.animal);

  Zoo copyWith({Animal? animal}) => Zoo(animal ?? this.animal);
}

// Test optics for type guard scenarios
final zooAnimal = Lens<Zoo, Animal>(
  getter: (z) => z.animal,
  setter: (z, a) => z.copyWith(animal: a),
);

final catName = Lens<Cat, String>(
  getter: (c) => c.name,
  setter: (c, v) => Cat(v),
);

// Helper extension for binding tests
extension SourceBindingHelpers on ApiPerson {
  SourceBinding<ApiPerson, Job?> get jobBinding =>
      SourceBinding(source: this, optic: PersonOptics.job);
}

final utf8Iso = Iso<String, List<int>>(
  getter: (s) => s.codeUnits,
  setter: (s, bytes) => String.fromCharCodes(bytes),
);
