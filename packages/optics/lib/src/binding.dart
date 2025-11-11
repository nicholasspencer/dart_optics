part of 'optical.dart';

/// A binding that combines a source value with an optic focused on it.
///
/// [SourceBinding] provides a convenient way to work with optics by pairing
/// a specific source value with an optic. This eliminates the need to pass
/// the source value to every optic operation, creating a more fluent API.
///
/// Think of a binding as a "pre-configured" optic that already knows what
/// value it's working with. You can call it to get the focus, use [set] to
/// update it, or [compound] to access deeper nested values.
///
/// Bindings are particularly useful in Flutter widgets where you want to
/// create derived state or update immutable models without repeatedly
/// passing the same object to optic operations.
///
/// ## Example
///
/// ```dart
/// final person = Person(
///   name: "Alice",
///   address: Address(street: "Main St"),
/// );
///
/// // Create a binding for the address
/// final addressBinding = SourceBinding(
///   source: person,
///   optic: PersonOptics.address,
/// );
///
/// // Get the current address
/// final currentAddress = addressBinding(); // Address(street: "Main St")
///
/// // Update to a new address
/// final movedPerson = addressBinding.set(
///   Address(street: "Oak Ave"),
/// );
///
/// // Compound to access nested fields
/// final streetBinding = addressBinding.compound(AddressOptics.street);
/// final street = streetBinding();              // "Main St"
/// final updated = streetBinding.set("Oak Ave"); // Person with new street
/// ```
final class SourceBinding<Source, Focus> {
  /// Creates a binding between a [source] value and an [optic].
  ///
  /// The [source] is the value being focused on, and the [optic] defines
  /// how to access and update the focus within that value.
  const SourceBinding({required this.source, required this.optic});

  /// The source value that this binding operates on.
  final Source source;

  /// The optic that defines how to access and update the focus.
  final Optical<Source, Focus> optic;

  /// Gets the focus value from the source.
  ///
  /// This is equivalent to calling `optic.get(source)` but with a more
  /// convenient syntax via the call operator.
  ///
  /// Example:
  /// ```dart
  /// final binding = SourceBinding(source: person, optic: nameLens);
  /// final name = binding(); // Gets person's name
  /// ```
  Focus call() => optic.getter(source);

  /// Creates a new source value with the focus updated to [value].
  ///
  /// Returns a new source value with the optic's focus set to [value].
  /// The original source is not mutated.
  ///
  /// Example:
  /// ```dart
  /// final binding = SourceBinding(source: person, optic: nameLens);
  /// final renamed = binding.set("Bob"); // New person with name "Bob"
  /// ```
  Source set(Focus value) => optic.setter(source, value);

  /// Composes this binding with another optic to access a deeper value.
  ///
  /// Creates a new binding that can access and update a [Resolution] value
  /// nested within this binding's focus. The new binding maintains the same
  /// source value but operates on a deeper path through the data structure.
  ///
  /// Note that compounding through nullable values (via [Prism] or
  /// [AffineTraversal]) will produce a binding with a nullable [Resolution].
  ///
  /// Example:
  /// ```dart
  /// final personBinding = SourceBinding(source: person, optic: identityIso);
  /// final addressBinding = personBinding.compound(PersonOptics.address);
  /// final streetBinding = addressBinding.compound(AddressOptics.street);
  ///
  /// final street = streetBinding();        // Gets person.address.street
  /// final updated = streetBinding.set("New St"); // Updates street
  /// ```
  SourceBinding<Source, Resolution?> compound<
    Through extends Focus?,
    Resolution
  >(Optical<Through, Resolution> through) {
    final optic = this.optic;

    return SourceBinding<Source, Resolution?>(
      source: source,
      optic: AffineTraversal(source: optic, through: through),
    );
  }

  /// Creates a new binding with the same optic but a different source value.
  ///
  /// This is useful when you want to reuse an optic configuration with
  /// different data, such as when rendering a list of items with the same
  /// optic operations.
  ///
  /// Example:
  /// ```dart
  /// final nameBinding = SourceBinding(source: person1, optic: nameLens);
  ///
  /// // Reuse the optic with a different person
  /// final otherBinding = nameBinding.bind(person2);
  /// final otherName = otherBinding(); // Gets person2's name
  /// ```
  SourceBinding<Source, Focus> bind(Source source) {
    return SourceBinding<Source, Focus>(source: source, optic: optic);
  }
}
