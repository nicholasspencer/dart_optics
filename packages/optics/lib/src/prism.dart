part of 'optical.dart';

class Prism<Source, Focus> extends Optical<Source, Focus?> {
  const Prism({required this.getter, required this.setter});

  @override
  final Accessor<Source, Focus?> getter;

  @override
  final Mutator<Source, Focus?> setter;

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
