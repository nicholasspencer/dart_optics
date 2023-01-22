import 'package:meta/meta.dart';

import 'optical.dart';

mixin PrismMixin<Source, Focus> on Optical<Source, Focus?> {}

@immutable
class Prism<Source, Focus> with Optical<Source, Focus?>, PrismMixin {
  const Prism({
    required this.getter,
    required this.setter,
  });

  static Prism<Source, Focus?> join<Source, Through, Focus>({
    required Optical<Source, Through?> sourcePrism,
    required Optical<Through, Focus?> throughPrism,
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

  @override
  Prism<Source, Refocus?> compound<Through extends Focus?, Refocus>(
    covariant PrismMixin<Through, Refocus?> optic,
  ) {
    return Prism.join<Source, Through, Refocus?>(
      sourcePrism: this as Optical<Source, Through?>,
      throughPrism: optic,
    );
  }
}

@immutable
class BoundPrism<Source, Focus> with Optical<Source, Focus?>, PrismMixin {
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

  @override
  BoundPrism<Source, Refocus?> compound<Through extends Focus?, Refocus>(
    covariant PrismMixin<Through, Refocus?> optic,
  ) {
    return BoundPrism(
      source: source,
      prism: Prism.join<Source, Through, Refocus?>(
        sourcePrism: this as Optical<Source, Through?>,
        throughPrism: optic,
      ),
    );
  }
}
