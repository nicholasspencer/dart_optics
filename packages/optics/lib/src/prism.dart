import 'package:meta/meta.dart';

import 'optic.dart';

@immutable
class Prism<Source, Focus> with Optic<Source, Focus?> {
  const Prism({
    required this.getter,
    required this.setter,
  });

  static Prism<Source, Focus?> compound<Source, Through, Focus>({
    required Optic<Source, Through?> sourcePrism,
    required Optic<Through, Focus?> throughPrism,
  }) =>
      Prism<Source, Focus?>(
        getter: (source) {
          final focus = sourcePrism.getter(source);

          if (focus == null) {
            return null;
          }

          return throughPrism.getter(focus);
        },
        setter: (source, value) {
          final focus = sourcePrism.getter(source);

          if (focus == null) {
            return source;
          }

          return sourcePrism.setter(
            source,
            throughPrism.setter(focus, value),
          );
        },
      );

  @override
  final Accessor<Source, Focus?> getter;

  @override
  final Mutator<Source, Focus?> setter;

  Focus? get(Source source) => getter(source);

  Source set(Source source, Focus? value) => setter(source, value);

  Source map({
    required Source source,
    required Focus? Function(Focus? focus) map,
  }) {
    return set(source, map(get(source)));
  }

  Prism<Source, Refocus?> compoundWithOptic<Through, Refocus>(
    Optic<Through, Refocus?> prism,
  ) {
    return Prism.compound<Source, Through, Refocus?>(
      sourcePrism: this as Optic<Source, Through?>,
      throughPrism: prism,
    );
  }

  Prism<Source, Refocus?> compoundWithThroughFactory<Through, Refocus>(
    CompoundOpticFactory<Through, Refocus?> factory,
  ) {
    return compoundWithOptic<Through, Refocus?>(
      Prism<Through, Refocus?>(
        getter: (focus) {
          return factory(focus).getter(focus);
        },
        setter: (focus, value) {
          return factory(focus).setter(focus, value);
        },
      ),
    );
  }
}

@immutable
class BoundPrism<Source, Focus> with Optic<Source, Focus?> {
  const BoundPrism({
    required this.source,
    required this.prism,
  });

  final Source source;

  final Prism<Source, Focus?> prism;

  Focus? call() => getter(source);

  Source set(Focus? newValue) => setter(source, newValue);

  @override
  Accessor<Source, Focus?> get getter => prism.getter;

  @override
  Mutator<Source, Focus?> get setter => prism.setter;

  Source map({required Focus? Function(Focus? focus) map}) => set(map(this()));

  BoundPrism<Source, Refocus?> compoundWithOptic<Refocus>(
    Optic<Focus, Refocus?> prism,
  ) {
    return BoundPrism(
      source: source,
      prism: Prism.compound(sourcePrism: this, throughPrism: prism),
    );
  }

  BoundPrism<Source, Refocus?> compoundWithThroughFactory<Refocus>(
    CompoundOpticFactory<Focus, Refocus?> factory,
  ) {
    return compoundWithOptic(
      Prism<Focus, Refocus?>(
        getter: (focus) {
          return factory(focus).getter(focus);
        },
        setter: (focus, value) {
          return factory(focus).setter(focus, value);
        },
      ),
    );
  }
}
