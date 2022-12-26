import 'package:meta/meta.dart';

typedef Accessor<Source, Focus> = Focus? Function(Source? source);

typedef Mutator<Source, Focus> = Source? Function(
  Source? source,
  Focus? value,
);

typedef CompoundLensFactory<Focus, Refocus> = Lensing<Focus?, Refocus?>?
    Function(Focus? focus);

mixin Lensing<Source, Focus> {
  Accessor<Source?, Focus?>? get getter;

  Mutator<Source?, Focus?>? get setter;

  Lensing<Source?, Refocus?> compoundWithLens<Refocus>(
    Lensing<Focus?, Refocus?>? lens,
  );

  Lensing<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
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
    required Lensing<Source?, Through?>? sourceLens,
    required Lensing<Through?, Focus?>? throughLens,
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
    Lensing<Focus?, Refocus?>? lens,
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
  BoundLens<Source?, Refocus?> compoundWithLens<Refocus>(
    Lensing<Focus?, Refocus?>? lens,
  ) {
    return BoundLens(
      source: source,
      lens: this.lens.compoundWithLens(lens),
    );
  }

  @override
  BoundLens<Source?, Refocus?> compoundWithFocusFactory<Refocus>(
    CompoundLensFactory<Focus?, Refocus>? factory,
  ) {
    return BoundLens(
      source: source,
      lens: lens.compoundWithFocusFactory(factory),
    );
  }
}
