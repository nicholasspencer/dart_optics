part of 'optical.dart';

/// A lens is an optic that focuses on a non-nullable field within a data structure.
///
/// Lenses are the most common type of optic, used when you know that the field
/// you're accessing always exists. They provide guaranteed access to a value
/// and the ability to update it functionally.
///
/// In the language of functional optics, a lens is a first-class value that
/// represents a "focus" on a particular field. Lenses compose with other lenses
/// to create accessors for deeply nested fields.
///
/// ## Composition
///
/// When composing lenses:
/// - Lens + Lens = Lens (guaranteed non-null path)
/// - Lens + Prism = AffineTraversal (path may fail due to null)
///
/// ## Example
///
/// ```dart
/// // Define a lens for a non-nullable field
/// final addressLens = Lens<Person, Address>(
///   getter: (person) => person.address,
///   setter: (person, address) => person.copyWith(address: address),
/// );
///
/// // Use it to view
/// final currentAddress = addressLens.get(person);
///
/// // Use it to update
/// final movedPerson = addressLens.set(person, newAddress);
///
/// // Compose lenses for deep access
/// final streetLens = Lens<Address, String>(
///   getter: (addr) => addr.street,
///   setter: (addr, st) => addr.copyWith(street: st),
/// );
/// final personStreet = addressLens.compound(streetLens);
/// final updated = personStreet.set(person, "New Street");
/// ```
class Lens<Source, Focus> extends Optical<Source, Focus> {
  /// Creates a lens with the given [getter] and [setter] functions.
  ///
  /// The [getter] extracts the focus from the source, and the [setter]
  /// creates a new source with an updated focus value.
  const Lens({required this.getter, required this.setter});

  @override
  final Accessor<Source, Focus> getter;

  @override
  final Mutator<Source, Focus> setter;

  /// Composes this lens with another optic.
  ///
  /// When composing with another [Lens], the result is a [Lens] that focuses
  /// on a nested non-nullable field. When composing with a [Prism] or other
  /// nullable optic, the result is an [AffineTraversal] since the path may
  /// encounter null values.
  ///
  /// Throws an [ArgumentError] if the intermediate value is not of the
  /// expected type during getter operations.
  @override
  Lens<Source, Resolution> compound<Through extends Focus?, Resolution>(
    Optical<Through, Resolution> optic,
  ) {
    return Lens<Source, Resolution>(
      getter: (source) {
        final through = getter(source);

        if (through is! Through) {
          throw ArgumentError(
            'Expected value of type $Through but got ${through.runtimeType}',
            'optic',
          );
        }

        return optic.getter(through);
      },
      setter: (source, value) {
        final through = getter(source);

        if (through is! Through) {
          return source;
        }

        final updatedThrough = optic.setter(through, value);

        if (updatedThrough is! Focus) {
          return source;
        }

        return setter(source, updatedThrough);
      },
    );
  }

  /// Converts this lens to a prism that focuses on a nullable value.
  ///
  /// This is useful when you need to compose a lens with other optics that
  /// expect nullable focus types. The resulting prism will only set the value
  /// if it's non-null.
  ///
  /// Example:
  /// ```dart
  /// final nameLens = Lens<Person, String>(...);
  /// final namePrism = nameLens.asPrism(); // Prism<Person, String?>
  /// ```
  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: (source, value) =>
          value is Focus ? setter(source, value) : source,
    );
  }
}
