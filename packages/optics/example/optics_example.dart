import 'package:optics/optics.dart';

import '../test/test_models.dart';

void main() {
  ApiPerson person = ApiPerson(
    name: 'Joe',
    address: Address(streetName: '123 Capital of Texas Hwy'),
  );

  assert(person.address.streetName == '123 Capital of Texas Hwy');

  /// Joe moved!
  person = person.addressOptic
      .compound(AddressOptics.streetName)
      .set('456 Mesa Dr');

  assert(person.address.streetName == '456 Mesa Dr');

  /// Joe got a job!
  person = SourceBinding(source: person, optic: PersonOptics.job).set(
    Job(
      address: Address(streetName: '789 E 6th St'),
      title: 'Sales bro',
    ),
  );

  assert(person.job?.title == 'Sales bro');

  final personJobTitle = PersonOptics.job.compound(JobOptics.title.asPrism());

  /// Joe got a promotion!
  person = personJobTitle.set(person, 'Executive sales bro');

  assert(person.job?.title == 'Executive sales bro');

  print(
    '''Howdy, ${person.name}!
You're ${personJobTitle.get(person)?.indefiniteArticle()} ${personJobTitle.get(person)}.
Nice place you've got @ ${person.addressOptic.compound(AddressOptics.streetName)()}.''',
  );
}
