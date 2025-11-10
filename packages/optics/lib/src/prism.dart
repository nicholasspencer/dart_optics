part of 'optical.dart';

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
