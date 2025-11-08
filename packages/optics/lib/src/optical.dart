import 'package:meta/meta.dart';

part 'lens.dart';
part 'prism.dart';

typedef Accessor<Source, Focus> = Focus Function(Source source);

typedef Mutator<Source, Focus> = Source Function(
  Source source,
  Focus value,
);

typedef AnyOptical = Optical<dynamic, dynamic>;

mixin Optical<Source, Focus> {
  AnyOptical compound<Through extends Focus, Refocus>(
    covariant AnyOptical optic,
  );

  Accessor<Source, Focus> get getter;

  Mutator<Source, Focus> get setter;
}
