import 'package:meta/meta.dart';

part 'binding.dart';
part 'iso.dart';
part 'lens.dart';
part 'prism.dart';
part 'traversal.dart';

/// A function that retrieves a [Focus] value from a [Source] value.
///
/// This is the "getter" half of an optic, allowing you to view into
/// a data structure.
typedef Accessor<Source, Focus> = Focus Function(Source source);

/// A function that produces a new [Source] value with an updated [Focus] value.
///
/// This is the "setter" half of an optic, allowing you to update immutable
/// data structures functionally without mutation.
typedef Mutator<Source, Focus> = Source Function(Source source, Focus value);

/// Type alias for optics with dynamic source and focus types.
///
/// Useful when you need to store optics of different types in collections
/// or pass them through APIs that don't preserve type parameters.
typedef AnyOptical = Optical<dynamic, dynamic>;

/// The base type for all optics in this library.
///
/// An optic is a composable abstraction for viewing and updating parts of
/// immutable data structures. All optics provide a [getter] to extract a
/// focus value from a source value, and a [setter] to produce a new source
/// value with an updated focus.
///
/// The optics hierarchy includes:
/// - [Iso]: An isomorphism between two types that can convert losslessly
/// - [Lens]: Focuses on a non-nullable field
/// - [Prism]: Focuses on a nullable field
/// - [AffineTraversal]: A composition of optics through nullable values
///
/// Optics can be composed using [compound] to create deep accessors into
/// nested data structures.
///
/// Example:
/// ```dart
/// final address = Lens<Person, Address>(
///   getter: (p) => p.address,
///   setter: (p, a) => p.copyWith(address: a),
/// );
///
/// final street = Lens<Address, String>(
///   getter: (a) => a.street,
///   setter: (a, s) => a.copyWith(street: s),
/// );
///
/// // Compose to access nested field
/// final personStreet = address.compound(street);
/// ```
@immutable
sealed class Optical<Source, Focus> {
  /// Creates an optic.
  const Optical();

  /// The function that extracts a [Focus] from a [Source].
  Accessor<Source, Focus> get getter;

  /// The function that creates a new [Source] with an updated [Focus].
  Mutator<Source, Focus> get setter;

  /// Extracts the focus value from [source].
  ///
  /// This is a convenience method that calls [getter].
  Focus get(Source source) => getter(source);

  /// Creates a new source value with the focus updated to [value].
  ///
  /// This is a convenience method that calls [setter].
  Source set(Source source, Focus value) => setter(source, value);

  /// Composes this optic with another optic to create a deeper accessor.
  ///
  /// The resulting optic can view and update a [Resolution] value nested
  /// within the [Focus] of this optic.
  ///
  /// The return type depends on the types of optics being composed:
  /// - Lens + Lens = Lens
  /// - Lens + Prism = AffineTraversal
  /// - Prism + any = AffineTraversal
  /// - Iso + Lens = Lens
  /// - Iso + Prism = Prism
  AnyOptical compound<Through extends Focus?, Resolution>(
    covariant AnyOptical optic,
  );
}
