import 'package:meta/meta.dart';

import 'optical.dart';
import 'prism.dart';

@immutable
class Lens<Source, Focus> with Optical<Source, Focus> {
  const Lens({
    required this.getter,
    required this.setter,
  });

  static Lens<Source, Focus> join<Source, Through, Focus>({
    required Optical<Source, Through> sourceLens,
    required Optical<Through, Focus> throughLens,
  }) =>
      Lens<Source, Focus>(
        getter: (source) {
          return throughLens.getter(
            sourceLens.getter(source),
          );
        },
        setter: (source, value) {
          return sourceLens.setter(
            source,
            throughLens.setter(
              sourceLens.getter(source),
              value,
            ),
          );
        },
      );

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
  Lens<Source, Refocus> compound<Through extends Focus, Refocus>(
    covariant Optical<Through, Refocus> optic,
  ) {
    return Lens.join<Source, Through, Refocus>(
      sourceLens: this as Optical<Source, Through>,
      throughLens: optic,
    );
  }

  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: (source, value) => setter(source, value as Focus),
    );
  }
}

@immutable
class BoundLens<Source, Focus> with Optical<Source, Focus> {
  const BoundLens({
    required this.source,
    required this.lens,
  });

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
  BoundLens<Source, Refocus> compound<Through extends Focus, Refocus>(
    covariant Optical<Through, Refocus> optic,
  ) {
    return BoundLens(
      source: source,
      lens: lens.compound(optic),
    );
  }

  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: (source, value) => setter(source, value as Focus),
    );
  }
}
