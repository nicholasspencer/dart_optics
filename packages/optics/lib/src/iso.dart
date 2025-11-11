part of 'optical.dart';

class Iso<Source, Focus> extends Optical<Source, Focus> {
  const Iso({required this.getter, required this.setter});

  const factory Iso.identity() = _Iso<Source, Focus>;

  @override
  final Accessor<Source, Focus> getter;

  @override
  final Mutator<Source, Focus> setter;

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

final class _Iso<Source, Focus> extends Iso<Source, Focus> {
  const _Iso() : super(getter: _identity, setter: _identitySetter);
}

Focus _identity<Source, Focus>(Source source) => source as Focus;
Source _identitySetter<Source, Focus>(Source source, Focus value) =>
    value as Source;

extension ObjectIso<Source> on Source {
  Iso<Source, Source> asIso() {
    return Iso<Source, Source>(
      getter: (source) => this,
      setter: (source, value) => value,
    );
  }
}
