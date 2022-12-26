import 'package:meta/meta.dart';

typedef Accessor<Source, Focus> = Focus? Function(Source? source);

typedef Mutator<Source, Focus> = Source? Function(
  Source? source,
  Focus? value,
);

typedef CompoundLensFactory<Focus, Refocus> = Lens<Focus?, Refocus?>? Function(
  Focus? focus,
);

@immutable
class Lens<Source, Focus> {
  const Lens({
    required this.accessor,
    required this.mutator,
  });

  final Accessor<Source?, Focus?>? accessor;

  final Mutator<Source?, Focus?>? mutator;

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

  Lens<Source?, Refocus?> compoundWithLens<Refocus>(
    Lens<Focus?, Refocus?>? lens,
  ) {
    return Lens.compound<Source?, Focus?, Refocus?>(
      sourceLens: this,
      throughLens: lens,
    );
  }

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
