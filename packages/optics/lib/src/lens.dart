import 'package:meta/meta.dart';

import 'optic.dart';

@immutable
class Lens<Source, Focus> with Optic<Source?, Focus?> {
  const Lens({
    required this.getter,
    required this.setter,
  });

  static Lens<Source?, Focus?> compound<Source, Through, Focus>({
    required Optic<Source?, Through?>? sourceLens,
    required Optic<Through?, Focus?>? throughLens,
  }) =>
      Lens<Source?, Focus?>(
        getter: (source) {
          return throughLens?.getter?.call(
            sourceLens?.getter?.call(source),
          );
        },
        setter: (source, value) {
          return sourceLens?.setter?.call(
            source,
            throughLens?.setter?.call(
              sourceLens.getter?.call(source),
              value,
            ),
          );
        },
      );

  @override
  final Accessor<Source?, Focus?>? getter;

  @override
  final Mutator<Source?, Focus?>? setter;

  Focus? get(Source? source) => getter?.call(source);

  Source? set(Source? source, Focus? value) => setter?.call(source, value);

  Source? map({required Focus? Function(Focus? focus) map, Source? source}) {
    return set(source, map(get(source)));
  }

  @override
  Lens<Source?, Refocus?> compoundWithOptic<Refocus>(
    Optic<Focus?, Refocus?>? lens,
  ) {
    return Lens.compound<Source?, Focus?, Refocus?>(
      sourceLens: this,
      throughLens: lens,
    );
  }

  @override
  Lens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundOpticFactory<Focus?, Refocus>? factory,
  ) {
    return compoundWithOptic<Refocus>(
      Lens<Focus?, Refocus?>(
        getter: (focus) {
          return factory?.call(focus)?.getter?.call(focus);
        },
        setter: (focus, value) {
          return factory?.call(focus)?.setter?.call(focus, value);
        },
      ),
    );
  }
}

@immutable
class BoundLens<Source, Focus> with Optic<Source?, Focus?> {
  const BoundLens({
    required this.source,
    required this.lens,
  });

  final Source source;

  final Lens<Source?, Focus?> lens;

  Focus? call() => getter?.call(source);

  Source? set(Focus? newValue) => setter?.call(source, newValue);

  @override
  Accessor<Source?, Focus?>? get getter => lens.getter;

  @override
  Mutator<Source?, Focus?>? get setter => lens.setter;

  Source? map({required Focus? Function(Focus? focus) map}) => set(map(this()));

  @override
  BoundLens<Source?, Refocus?> compoundWithOptic<Refocus>(
    Optic<Focus?, Refocus?>? lens,
  ) {
    return BoundLens(
      source: source,
      lens: this.lens.compoundWithOptic(lens),
    );
  }

  @override
  BoundLens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundOpticFactory<Focus?, Refocus>? factory,
  ) {
    return BoundLens(
      source: source,
      lens: lens.compoundWithFocusFactory(factory),
    );
  }
}
