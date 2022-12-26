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
  Accessor<Source?, Focus?>? get accessor;

  Mutator<Source?, Focus?>? get mutator;

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
    required this.accessor,
    required this.mutator,
  });

  static Lens<Source?, Focus?> compound<Source, Through, Focus>({
    required Lens<Source?, Through?>? sourceLens,
    required Lens<Through?, Focus?>? throughLens,
  }) =>
      Lens<Source?, Focus?>(
        accessor: (source) {
          return throughLens?.accessor?.call(
            sourceLens?.accessor?.call(source),
          );
        },
        mutator: (source, value) {
          return sourceLens?.mutator?.call(
            source,
            throughLens?.mutator?.call(
              sourceLens.accessor?.call(source),
              value,
            ),
          );
        },
      );

  @override
  final Accessor<Source?, Focus?>? accessor;

  @override
  final Mutator<Source?, Focus?>? mutator;

  Focus? view(Source? source) => accessor?.call(source);

  Source? mutate(Source? source, Focus? value) => mutator?.call(source, value);

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
        accessor: (focus) {
          return factory?.call(focus)?.accessor?.call(focus);
        },
        mutator: (focus, value) {
          return factory?.call(focus)?.mutator?.call(focus, value);
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

  Focus? call() => accessor?.call(source);

  Source? mutate(Focus? newValue) => mutator?.call(source, newValue);

  @override
  Accessor<Source?, Focus?>? get accessor => lens.accessor;

  @override
  Mutator<Source?, Focus?>? get mutator => lens.mutator;

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
