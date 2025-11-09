part of 'optical.dart';

@immutable
class Prism<Source, Focus> extends Optical<Source, Focus?> {
  const Prism({required this.getter, required this.setter});

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
  AffineTraversal<Source, Focus, Through, Resolution?> compound<
    Through extends Focus?,
    Resolution
  >(Optical<Through, Resolution> optic) {
    return AffineTraversal<Source, Focus, Through, Resolution?>(
      source: this,
      through: optic,
    );
  }
}

@immutable
class BoundPrism<Source, Focus> extends Optical<Source, Focus?> {
  const BoundPrism({required this.source, required this.prism});

  final Source source;

  final Optical<Source, Focus?> prism;

  Focus? call() => getter(source);

  Source set(Focus? newValue) => setter(source, newValue);

  @override
  Accessor<Source, Focus?> get getter => prism.getter;

  @override
  Mutator<Source, Focus?> get setter => prism.setter;

  Source map({required Focus? Function(Focus? focus) map}) => set(map(this()));

  @override
  BoundPrism<Source, Resolution?> compound<Through extends Focus?, Resolution>(
    Optical<Through, Resolution> optic,
  ) {
    return BoundPrism(
      source: source,
      prism: AffineTraversal<Source, Focus, Through, Resolution?>(
        source: this,
        through: optic,
      ),
    );
  }
}
