import 'package:meta/meta.dart';

import 'optical.dart';
import 'prism.dart';

@immutable
class Lens<Source, Focus> with Optical<Source, Focus> {
  const Lens({
    required this.getter,
    required this.setter,
  });

  static Lens<Source, Focus> compound<Source, Through, Focus>({
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

  Lens<Source, Refocus> compoundWithOptical<Refocus>(
    Optical<Focus, Refocus> lens,
  ) {
    return Lens.compound<Source, Focus, Refocus>(
      sourceLens: this,
      throughLens: lens,
    );
  }

  Lens<Source, Refocus> compoundWithThroughFactory<Refocus>(
    CompoundOpticFactory<Focus, Refocus> factory,
  ) {
    return compoundWithOptical<Refocus>(
      Lens<Focus, Refocus>(
        getter: (focus) {
          return factory(focus).getter(focus);
        },
        setter: (focus, value) {
          return factory(focus).setter(focus, value);
        },
      ),
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

  Source map({required Focus Function(Focus focus) map}) => set(map(this()));

  BoundLens<Source, Refocus> compoundWithOptical<Refocus>(
    Optical<Focus, Refocus> lens,
  ) {
    return BoundLens(
      source: source,
      lens: this.lens.compoundWithOptical(lens),
    );
  }

  BoundLens<Source, Refocus> compoundWithThroughFactory<Refocus>(
    CompoundOpticFactory<Focus, Refocus> factory,
  ) {
    return BoundLens(
      source: source,
      lens: lens.compoundWithThroughFactory(factory),
    );
  }

  Prism<Source, Focus?> asPrism() {
    return Prism<Source, Focus?>(
      getter: getter,
      setter: setter as Mutator<Source, Focus?>,
    );
  }
}
