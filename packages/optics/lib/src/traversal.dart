part of 'optical.dart';

/// An affine traversal is an optic that represents a path through potentially
/// nullable intermediate values.
///
/// In functional optics, an affine traversal is a composition of optics where
/// at least one step in the path may fail (return null). This happens when
/// composing with [Prism]s or other nullable optics. The "affine" qualifier
/// means the traversal can focus on at most one value (as opposed to a general
/// traversal which might focus on multiple values).
///
/// Affine traversals are typically created automatically when you compose
/// optics that involve nullable values. You rarely need to construct them
/// directly - they're the result of composing lenses and prisms together.
///
/// ## Creation
///
/// Affine traversals are created implicitly through composition:
/// - Lens + Prism → AffineTraversal
/// - Prism + Lens → AffineTraversal
/// - Prism + Prism → AffineTraversal
/// - AffineTraversal + any optic → AffineTraversal
///
/// ## Behavior
///
/// - **Getting**: Returns null if any step in the path encounters a null value
/// - **Setting**: Only updates if all intermediate values are non-null,
///   otherwise returns the original source unchanged
///
/// ## Example
///
/// ```dart
/// // person.job is nullable, so this creates an AffineTraversal
/// final jobTitle = PersonOptics.job.compound(JobOptics.title);
///
/// // Getting returns null if person has no job
/// final title = jobTitle.get(unemployedPerson); // null
/// final title2 = jobTitle.get(employedPerson);  // "Engineer"
///
/// // Setting is a no-op if person has no job
/// final stillUnemployed = jobTitle.set(unemployedPerson, "Manager");
/// // ^ same as unemployedPerson, job is still null
///
/// final promoted = jobTitle.set(employedPerson, "Senior Engineer");
/// // ^ person with updated job title
/// ```
///
/// See also:
/// - [Lens], which guarantees non-null access
/// - [Prism], which handles a single nullable value
/// - [compound], for further composition
class AffineTraversal<Source, Focus, Through extends Focus?, Resolution>
    extends Optical<Source, Resolution?> {
  /// Creates an affine traversal by composing a [source] optic with a
  /// [through] optic.
  ///
  /// This constructor is typically used internally by the library when
  /// composing optics. Most users will create affine traversals implicitly
  /// through the [compound] method on other optics.
  ///
  /// The [source] optic accesses an intermediate value from the source, and
  /// the [through] optic accesses the final resolution from that intermediate
  /// value. If either step returns null, the entire path fails.
  const AffineTraversal({
    required Optical<Source, Focus?> source,
    required Optical<Through, Resolution?> through,
  }) : _source = source,
       _through = through;

  final Optical<Source, Focus?> _source;

  final Optical<Through, Resolution?> _through;

  /// The source optic, normalized to handle nullable values.
  ///
  /// If the source is a [Lens], it's converted to a [Prism] to handle
  /// the nullable path correctly.
  Optical<Source, Focus?> get source => switch (_source) {
    Lens<Source, Focus>() => _source.asPrism(),
    Optical<Source, Focus?>() => _source,
  };

  /// The through optic, normalized to handle nullable values.
  ///
  /// If the through optic is a [Lens], it's converted to a [Prism] to handle
  /// the nullable path correctly.
  Optical<Through, Resolution?> get through => switch (_through) {
    Lens<Through, Resolution>() => _through.asPrism(),
    Optical<Through, Resolution?>() => _through,
  };

  @override
  Accessor<Source, Resolution?> get getter => (source) {
    var throughValue = this.source.getter(source);

    if (throughValue is! Through) {
      return null;
    }

    return through.getter(throughValue);
  };

  @override
  Mutator<Source, Resolution?> get setter => (source, value) {
    var throughValue = this.source.getter(source);

    if (throughValue is! Through) {
      return source;
    }

    return this.source.setter(source, through.setter(throughValue, value));
  };

  /// Composes this affine traversal with another optic to create a deeper
  /// traversal.
  ///
  /// The resulting traversal extends the path through another optic.
  /// Since affine traversals already represent potentially failing paths,
  /// any further composition also produces an affine traversal.
  ///
  /// Example:
  /// ```dart
  /// // person.job is nullable
  /// final jobAddress = PersonOptics.job.compound(JobOptics.address);
  /// // jobAddress is AffineTraversal<Person, Job, Job, Address?>
  ///
  /// // Compound further to get street
  /// final jobStreet = jobAddress.compound(AddressOptics.street);
  /// // jobStreet is AffineTraversal<Person, Address, Address, String?>
  ///
  /// final street = jobStreet.get(person); // null if no job
  /// ```
  @override
  AffineTraversal<Source, Resolution, NewThrough, NewResolution?> compound<
    NewThrough extends Resolution?,
    NewResolution
  >(Optical<NewThrough, NewResolution> optic) {
    return AffineTraversal<Source, Resolution, NewThrough, NewResolution?>(
      source: this,
      through: optic,
    );
  }
}
