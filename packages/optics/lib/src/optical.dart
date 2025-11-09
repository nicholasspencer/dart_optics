import 'package:meta/meta.dart';

part 'lens.dart';
part 'prism.dart';
part 'traversal.dart';

typedef Accessor<Source, Focus> = Focus Function(Source source);

typedef Mutator<Source, Focus> = Source Function(Source source, Focus value);

typedef AnyOptical = Optical<dynamic, dynamic>;

sealed class Optical<Source, Focus> {
  const Optical();

  Accessor<Source, Focus> get getter;

  Mutator<Source, Focus> get setter;

  AnyOptical compound<Through extends Focus?, Resolution>(
    covariant AnyOptical optic,
  );
}
