import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:optics/optics.dart';

part 'test_models.freezed.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String name,
    required Address address,
    Job? job,
  }) = _Person;
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

extension PersonOptics on Person {
  static final Lens<Person, Address> address = Lens(
    getter: (subject) => subject.address,
    setter: (subject, value) => subject.copyWith(address: value),
  );

  static final Lens<Person, String> addressName = address.compound(
    AddressOptics.streetName,
  );

  static final Prism<Person, Job?> job = Prism(
    getter: (subject) => subject.job,
    setter: (subject, value) => subject.copyWith(job: value),
  );

  static final jobTitle = job.compound(JobOptics.title);

  static final jobAddressName = AffineTraversal(
    source: AffineTraversal(source: job, through: JobOptics.address),
    through: AddressOptics.streetName,
  );

  SourceBinding<Person, Address> get addressOptic =>
      SourceBinding(source: this, optic: address);

  Prism<Person, Job?> get jobOptic => asIso().compoundPrism(job);

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
