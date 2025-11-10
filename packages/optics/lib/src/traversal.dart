part of 'optical.dart';

class AffineTraversal<Source, Focus, Through extends Focus?, Resolution>
    extends Optical<Source, Resolution?> {
  const AffineTraversal({
    required Optical<Source, Focus?> source,
    required Optical<Through, Resolution?> through,
  }) : _source = source,
       _through = through;

  final Optical<Source, Focus?> _source;

  final Optical<Through, Resolution?> _through;

  Optical<Source, Focus?> get source => switch (_source) {
    Lens<Source, Focus>() => _source.asPrism(),
    Optical<Source, Focus?>() => _source,
  };

  Optical<Through, Resolution?> get through => switch (_through) {
    Lens<Through, Resolution>() => _through.asPrism(),
    Optical<Through, Resolution?>() => _through,
  };

  @override
  Accessor<Source, Resolution?> get getter => (source) {
    var throughValue = this.source.getter(source);

    if (throughValue is! Through) {
      return null;
    }

    return through.getter(throughValue);
  };

  @override
  Mutator<Source, Resolution?> get setter => (source, value) {
    var throughValue = this.source.getter(source);

    if (throughValue is! Through) {
      return source;
    }

    return this.source.setter(source, through.setter(throughValue, value));
  };

  Resolution? get(Source source) => getter(source);

  Source set(Source source, Resolution? value) => setter(source, value);

  Source map({
    required Source source,
    required Resolution? Function(Resolution? focus) map,
  }) {
    return set(source, map(get(source)));
  }

  @override
  AffineTraversal<Source, Resolution, NewThrough, NewResolution?> compound<
    NewThrough extends Resolution?,
    NewResolution
  >(Optical<NewThrough, NewResolution> optic) {
    return AffineTraversal<Source, Resolution, NewThrough, NewResolution?>(
      source: this,
      through: optic,
    );
  }
}
