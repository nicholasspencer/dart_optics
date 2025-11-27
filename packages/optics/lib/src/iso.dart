part of 'optical.dart';

/// An isomorphism (Iso) is an optic representing a lossless, bidirectional
/// conversion between two types.
///
/// An iso is the strongest form of optic - it guarantees that you can convert
/// between [Source] and [Focus] in both directions without losing information.
/// This means you can go from Source → Focus → Source and end up with exactly
/// what you started with.
///
/// In functional optics, an isomorphism is both a lens (guaranteed access) and
/// a prism (guaranteed construction). Isos are useful for representing different
/// views of the same data, such as encoding/decoding, parsing/serializing, or
/// different representations of the same information.
///
/// ## Composition
///
/// Isos preserve the strength of the optics they compose with:
/// - Iso + Lens = Lens (still guaranteed non-null)
/// - Iso + Prism = Prism (still handles nullability correctly)
/// - Iso + Iso = Iso (still fully bidirectional)
///
/// ## Example
///
/// ```dart
/// // An iso between String and List<int> (UTF-8 encoding)
/// final utf8Iso = Iso<String, List<int>>(
///   getter: (s) => s.codeUnits,
///   setter: (s, bytes) => String.fromCharCodes(bytes),
/// );
///
/// final text = "Hello";
/// final bytes = utf8Iso.get(text);        // [72, 101, 108, 108, 111]
/// final back = utf8Iso.set(text, bytes);  // "Hello"
///
/// // Identity iso (useful for starting chains)
/// final personIso = Iso<Person, Person>.identity();
/// ```
class Iso<Source, Focus> extends Optical<Source, Focus> {
  /// Creates an isomorphism with the given [to] and [from] functions.
  ///
  /// The [to] converts from [Source] to [Focus], and the [from]
  /// converts from [Focus] back to [Source]. These should be inverse
  /// operations for a true isomorphism.
  const Iso({required this.to, required this.from});

  /// Creates an identity isomorphism where [Source] and [Focus] are the same.
  ///
  /// The identity iso simply returns its input unchanged in both directions.
  /// This is useful as a starting point for optic composition.
  const factory Iso.identity() = _Iso<Source, Focus>;

  final Accessor<Source, Focus> to;

  final Mutator<Source, Focus> from;

  @override
  Accessor<Source, Focus> get getter => to;

  @override
  Mutator<Source, Focus> get setter => from;

  /// Composes this iso with another optic, preserving optic strength.
  ///
  /// The type of the resulting optic depends on what's being composed:
  /// - With a [Lens]: Returns a [Lens] (preserves non-null guarantee)
  /// - With a [Prism]: Returns a [Prism] (preserves nullable handling)
  /// - With other optics: Returns an [AffineTraversal]
  ///
  /// This specialized composition behavior allows isos to maintain the
  /// strongest possible type when composed with other optics.
  @override
  Optical<Source, Resolution?> compound<Through extends Focus?, Resolution>(
    Optical<Through, Resolution?> optic,
  ) {
    return switch (optic) {
      Lens<Through, Resolution>() => compoundLens(optic),
      Prism<Through, Resolution>() => compoundPrism(optic),
      Optical<Through, Resolution?>() =>
        AffineTraversal<Source, Focus, Through, Resolution>(
          source: this,
          through: optic,
        ),
    };
  }

  /// Composes this iso with a lens to create a lens.
  ///
  /// Since both isos and lenses guarantee access to their focus,
  /// composing them produces another lens with guaranteed access.
  ///
  /// Throws an [ArgumentError] if the intermediate value is not of the
  /// expected type during getter operations.
  Lens<Source, Resolution> compoundLens<Through extends Focus?, Resolution>(
    Lens<Through, Resolution> optic,
  ) {
    return Lens<Source, Resolution>(
      getter: (source) {
        final through = getter(source);

        if (through is! Through) {
          throw ArgumentError(
            'Expected value of type $Through but got ${optic.runtimeType}',
            'optic',
          );
        }

        final resolution = optic.getter(through);

        return resolution;
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

  /// Composes this iso with a prism to create a prism.
  ///
  /// The resulting prism maintains the nullable behavior of the original
  /// prism while transforming through the iso's conversion.
  Prism<Source, Resolution?> compoundPrism<Through extends Focus?, Resolution>(
    Prism<Through, Resolution?> optic,
  ) {
    return Prism<Source, Resolution?>(
      getter: (source) {
        final through = getter(source);

        if (through is! Through) {
          return null;
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
}

/// Private implementation of identity iso.
final class _Iso<Source, Focus> extends Iso<Source, Focus> {
  const _Iso() : super(to: _identity, from: _identitySetter);
}

Focus _identity<Source, Focus>(Source source) => source as Focus;
Source _identitySetter<Source, Focus>(Source source, Focus value) =>
    value as Source;

/// Extension to create an identity isomorphism from any value.
///
/// This is useful for starting optic composition chains or when you need
/// to treat a value as an optic.
extension ObjectIso<Source> on Source {
  /// Creates an identity iso for this object.
  ///
  /// The returned iso doesn't transform the value - it simply provides
  /// an optic interface around the identity function.
  ///
  /// Example:
  /// ```dart
  /// final person = Person(name: "Alice", /*...*/);
  /// final personIso = person.asIso();
  ///
  /// // Can now compose with other optics
  /// final nameOptic = personIso.compoundLens(PersonOptics.name);
  /// ```
  Iso<Source, Source> asIso() {
    return Iso<Source, Source>(
      to: (source) => this,
      from: (source, value) => value,
    );
  }
}
