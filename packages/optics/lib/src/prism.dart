part of 'optical.dart';

/// A prism is an optic that focuses on a nullable or optional field.
///
/// Prisms represent partial access to a value - the value may or may not be
/// present. This makes them ideal for optional fields, nullable types, or
/// sum types where you're focusing on one particular case.
///
/// In functional programming, a prism is an optic that can fail to get a value
/// but always succeeds in setting one (though the set may be a no-op if the
/// value is null).
///
/// ## Composition
///
/// When a prism is composed with any other optic, the result is an
/// [AffineTraversal] because the path may fail at any point where a null
/// value is encountered.
///
/// - Prism + Lens = AffineTraversal
/// - Prism + Prism = AffineTraversal
///
/// ## Example
///
/// ```dart
/// // Define a prism for an optional field
/// final jobPrism = Prism<Person, Job?>(
///   getter: (person) => person.job,
///   setter: (person, job) => person.copyWith(job: job),
/// );
///
/// // Getting may return null
/// final currentJob = jobPrism.get(person); // Job? or null
///
/// // Setting handles null gracefully
/// final employed = jobPrism.set(person, someJob);
/// final unemployed = jobPrism.set(person, null);
///
/// // Compose with other optics (creates AffineTraversal)
/// final jobTitle = jobPrism.compound(titleLens);
/// final title = jobTitle.get(person); // null if person has no job
/// ```
class Prism<Source, Focus> extends Optical<Source, Focus?> {
  /// Creates a prism with the given [getter] and [setter] functions.
  ///
  /// The [getter] extracts a potentially null focus from the source.
  /// The [setter] creates a new source with an updated focus value,
  /// or returns the original source if the value is null.
  const Prism({required this.getter, required this.setter});

  @override
  final Accessor<Source, Focus?> getter;

  @override
  final Mutator<Source, Focus?> setter;

  /// Composes this prism with another optic to create an [AffineTraversal].
  ///
  /// The resulting traversal represents a path through potentially nullable
  /// values. The getter will return null if this prism's focus is null, or if
  /// the composed optic's focus is null. The setter will only apply changes
  /// if all intermediate values are non-null.
  ///
  /// Example:
  /// ```dart
  /// final jobPrism = Prism<Person, Job?>(/*...*/);
  /// final titleLens = Lens<Job, String>(/*...*/);
  ///
  /// // Creates AffineTraversal<Person, Job, Job, String?>
  /// final jobTitlePath = jobPrism.compound(titleLens);
  ///
  /// // Returns null if person.job is null
  /// final title = jobTitlePath.get(person);
  /// ```
  @override
  AffineTraversal<Source, Focus, Through, Resolution?> compound<
    Through extends Focus?,
    Resolution
  >(Optical<Through, Resolution> optic) {
    return AffineTraversal<Source, Focus, Through, Resolution?>(
      source: this,
      through: optic,
    );
  }
}
