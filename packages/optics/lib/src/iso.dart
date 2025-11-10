part of 'optical.dart';

class Iso<Source> extends Optical<Source, Source> {
  const Iso({required this.getter, required this.setter});

  const factory Iso.identity() = _Iso<Source>;

  @override
  final Accessor<Source, Source> getter;

  @override
  final Mutator<Source, Source> setter;

  @override
  Optical<Source, Resolution?> compound<Through extends Source?, Resolution>(
    Optical<Through, Resolution?> optic,
  ) {
    return switch (optic) {
      Lens<Through, Resolution>() => compoundLens(optic),
      Prism<Through, Resolution?>() => compoundPrism(optic),
      Optical<Through, Resolution?>() =>
        AffineTraversal<Source, Source, Through, Resolution?>(
          source: this,
          through: optic,
        ),
    };
  }

  Lens<Source, Resolution> compoundLens<Through extends Source?, Resolution>(
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

        if (updatedThrough is! Source) {
          return source;
        }

        return setter(source, updatedThrough);
      },
    );
  }

  Prism<Source, Resolution?> compoundPrism<Through extends Source?, Resolution>(
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

        if (updatedThrough is! Source) {
          return source;
        }

        return setter(source, updatedThrough);
      },
    );
  }
}

final class _Iso<Source> extends Iso<Source> {
  const _Iso() : super(getter: _identity, setter: _identitySetter);
}

Source _identity<Source>(Source source) => source;
Source _identitySetter<Source>(Source source, Source value) => value;

extension ObjectIso<Source> on Source {
  Iso<Source> asIso() {
    return Iso<Source>(
      getter: (source) => this,
      setter: (source, value) => value,
    );
  }
}
