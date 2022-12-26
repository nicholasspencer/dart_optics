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
    required Accessor<Source?, Focus?>? accessor,
    required Mutator<Source?, Focus?>? mutator,
  })  : view = accessor,
        mutate = mutator;

  final Accessor<Source?, Focus?>? view;

  final Mutator<Source?, Focus?>? mutate;

  static Lens<Source?, Focus?> compound<Source, Through, Focus>({
    required Lens<Source?, Through?>? sourceLens,
    required Lens<Through?, Focus?>? throughLens,
  }) =>
      Lens<Source?, Focus?>(
        accessor: (source) {
          return throughLens?.view?.call(
            sourceLens?.view?.call(source),
          );
        },
        mutator: (source, value) {
          return sourceLens?.mutate?.call(
            source,
            throughLens?.mutate?.call(sourceLens.view?.call(source), value),
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
          return factory?.call(focus)?.view?.call(focus);
        },
        mutator: (focus, value) {
          return factory?.call(focus)?.mutate?.call(focus, value);
        },
      ),
    );
  }
}
