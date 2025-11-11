# Optics 🔍

A functional optics library for Dart that makes working with immutable data structures elegant and composable. Perfect for Flutter apps that rely on immutable state management.

## What are Optics?

Optics are composable abstractions for viewing and updating parts of immutable data structures. Instead of manually copying objects with updated fields, optics provide a declarative way to focus on specific parts of your data and transform them functionally.

Think of optics as "functional getters and setters" that compose together to access deeply nested data.

## Core Concepts

### Optical

`Optical` is the base type for all optics. Every optic provides:

- A **getter** to extract a focus value from a source
- A **setter** to create a new source with an updated focus
- A **compound** method to compose with other optics

```dart
// Every optic can get and set
final address = addressLens.get(person);
final updated = addressLens.set(person, newAddress);
```

### Lens

A `Lens` focuses on a **non-nullable field** within a data structure. Use lenses when you're accessing fields that are guaranteed to exist.

```dart
final addressLens = Lens<Person, Address>(
  getter: (person) => person.address,
  setter: (person, address) => person.copyWith(address: address),
);

// Get the current address
final currentAddress = addressLens.get(person);

// Update the address
final movedPerson = addressLens.set(person, newAddress);
```

### Prism

A `Prism` focuses on a **nullable or optional field**. Use prisms when the value you're accessing might not be present.

```dart
final jobPrism = Prism<Person, Job?>(
  getter: (person) => person.job,
  setter: (person, job) => person.copyWith(job: job),
);

// Getting may return null
final currentJob = jobPrism.get(person); // Job? or null

// Setting handles null gracefully
final employed = jobPrism.set(person, someJob);
final unemployed = jobPrism.set(person, null);
```

## Composition

The real power of optics comes from composition. You can combine optics to access deeply nested fields without manual drilling.

### Composing Lenses

When you compose two lenses, you get another lens that focuses on the nested field:

```dart
final addressLens = Lens<Person, Address>(
  getter: (p) => p.address,
  setter: (p, a) => p.copyWith(address: a),
);

final streetLens = Lens<Address, String>(
  getter: (a) => a.street,
  setter: (a, s) => a.copyWith(street: s),
);

// Compose them to access person's street directly
final personStreetLens = addressLens.compound(streetLens);

final street = personStreetLens.get(person);  // "Main St"
final updated = personStreetLens.set(person, "Oak Ave");
```

### Composing with Prisms

When you compose lenses and prisms (or multiple prisms), the result handles nullable paths gracefully:

```dart
final jobPrism = Prism<Person, Job?>(/*...*/);
final titleLens = Lens<Job, String>(/*...*/);

// Compose to access job title (may be null if no job)
final jobTitleOptic = jobPrism.compound(titleLens);

final title = jobTitleOptic.get(employedPerson);   // "Engineer"
final noTitle = jobTitleOptic.get(unemployedPerson); // null

// Setting only works if person has a job
final promoted = jobTitleOptic.set(employedPerson, "Senior Engineer");
final stillUnemployed = jobTitleOptic.set(unemployedPerson, "CEO");
// ^ No change, person still has no job
```

## Binding

`SourceBinding` pairs a specific value with an optic, creating a fluent API that eliminates repetitive source passing. This is especially useful in Flutter widgets.

```dart
final person = Person(
  name: "Alice",
  address: Address(street: "Main St"),
);

// Create a binding
final addressBinding = SourceBinding(
  source: person,
  optic: PersonOptics.address,
);

// Call to get the value
final currentAddress = addressBinding();

// Set to update
final movedPerson = addressBinding.set(newAddress);

// Compound to go deeper
final streetBinding = addressBinding.compound(AddressOptics.street);
final street = streetBinding();              // "Main St"
final updated = streetBinding.set("Oak Ave"); // Person with updated street
```

### Extension Pattern

A common pattern is to add optics as extensions on your models:

```dart
extension PersonOptics on Person {
  static final address = Lens<Person, Address>(
    getter: (p) => p.address,
    setter: (p, a) => p.copyWith(address: a),
  );

  static final job = Prism<Person, Job?>(
    getter: (p) => p.job,
    setter: (p, j) => p.copyWith(job: j),
  );

  // Convenience binding getter
  SourceBinding<Person, Address> get addressOptic =>
      SourceBinding(source: this, optic: address);
}

// Now you can use it fluently
final person = Person(/*...*/);
final street = person.addressOptic
    .compound(AddressOptics.street)();

final moved = person.addressOptic
    .compound(AddressOptics.street)
    .set("New Street");
```

## Why Use Optics?

**✨ Type-safe**: All operations are fully type-checked at compile time

**🔗 Composable**: Build complex accessors from simple building blocks

**📖 Readable**: Express intent clearly without nested `copyWith` calls

**♻️ Reusable**: Define optics once, use them throughout your app

**🎯 Functional**: Work with immutable data without ceremony

## Use Cases

- **State Management**: Update nested state in Redux, Bloc, or Riverpod
- **Form Handling**: Focus on individual form fields in complex models
- **API Responses**: Transform deeply nested JSON data
- **Configuration**: Access and update app settings
- **Testing**: Create test data variations with minimal boilerplate

## License

See the [LICENSE](LICENSE) file for details.
