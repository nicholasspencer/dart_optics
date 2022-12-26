import 'package:meta/meta.dart';

typedef Accessor<Source, Focus> = Focus? Function(Source? source);

typedef Mutator<Source, Focus> = Source? Function(
  Source? source,
  Focus? value,
);

typedef CompoundLensFactory<Focus, Refocus> = Lens<Focus?, Refocus?>? Function(
  Focus? focus,
);

mixin Lensing<Source, Focus> {
  Accessor<Source?, Focus?>? get getter;

  Mutator<Source?, Focus?>? get setter;

  Lens<Source?, Refocus?> compoundWithLens<Refocus>(
    Lens<Focus?, Refocus?>? lens,
  );

  Lens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundLensFactory<Focus?, Refocus>? factory,
  );
}

@immutable
class Lens<Source, Focus> with Lensing<Source?, Focus?> {
  const Lens({
    required this.getter,
    required this.setter,
  });

  static Lens<Source?, Focus?> compound<Source, Through, Focus>({
    required Lens<Source?, Through?>? sourceLens,
    required Lens<Through?, Focus?>? throughLens,
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

  @override
  Lens<Source?, Refocus?> compoundWithLens<Refocus>(
    Lens<Focus?, Refocus?>? lens,
  ) {
    return Lens.compound<Source?, Focus?, Refocus?>(
      sourceLens: this,
      throughLens: lens,
    );
  }

  @override
  Lens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundLensFactory<Focus?, Refocus>? factory,
  ) {
    return compoundWithLens<Refocus>(
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
class BoundLens<Source, Focus> with Lensing<Source?, Focus?> {
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

  @override
  Lens<Source?, Refocus?> compoundWithLens<Refocus>(
    Lens<Focus?, Refocus?>? lens,
  ) {
    return this.lens.compoundWithLens(lens);
  }

  @override
  Lens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundLensFactory<Focus?, Refocus>? factory,
  ) {
    return lens.compoundWithFocusFactory(factory);
  }
}
