part of 'optical.dart';

final class SourceBinding<Source, Focus> {
  const SourceBinding({required this.source, required this.optic});

  final Source source;

  final Optical<Source, Focus> optic;

  Focus call() => optic.getter(source);

  Source set(Focus value) => optic.setter(source, value);

  SourceBinding<Source, Resolution?> compound<
    Through extends Focus?,
    Resolution
  >(Optical<Through, Resolution> through) {
    final optic = this.optic;

    return SourceBinding<Source, Resolution?>(
      source: source,
      optic: AffineTraversal(source: optic, through: through),
    );
  }

  SourceBinding<Source, Focus> bind(Source source) {
    return SourceBinding<Source, Focus>(source: source, optic: optic);
  }
}
