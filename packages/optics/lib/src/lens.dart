part of 'optical.dart';

@immutable
class Lens<Source, Focus> extends Optical<Source, Focus> {
  const Lens({required this.getter, required this.setter});

  @override
  final Accessor<Source, Focus> getter;

  @override
  final Mutator<Source, Focus> setter;

  Focus get(Source source) => getter(source);

  Source set(Source source, Focus value) => setter(source, value);

  Source map({
    required Source source,
    required Focus Function(Focus focus) map,
  }) {
    return set(source, map(get(source)));
  }

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

  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: (source, value) =>
          value is Focus ? setter(source, value) : source,
    );
  }
}

@immutable
class BoundLens<Source, Focus> extends Optical<Source, Focus> {
  const BoundLens({required this.source, required this.lens});

  final Source source;

  final Lens<Source, Focus> lens;

  Focus call() => getter(source);

  Source set(Focus newValue) => setter(source, newValue);

  @override
  Accessor<Source, Focus> get getter => lens.getter;

  @override
  Mutator<Source, Focus> get setter => lens.setter;

  Source map(Focus Function(Focus focus) map) => set(map(this()));

  @override
  BoundLens<Source, Resolution> compound<Through extends Focus?, Resolution>(
    Optical<Through, Resolution> optic,
  ) {
    return BoundLens(source: source, lens: lens.compound(optic));
  }

  @protected
  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: (source, value) =>
          value is Focus ? setter(source, value) : source,
    );
  }
}
