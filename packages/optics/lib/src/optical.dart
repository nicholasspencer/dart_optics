typedef Accessor<Source, Focus> = Focus Function(Source source);

typedef Mutator<Source, Focus> = Source Function(
  Source source,
  Focus value,
);

mixin Optical<Source, Focus> {
  Optical compound<Through extends Focus, Refocus>(
    Optical optic,
  );

  Accessor<Source, Focus> get getter;

  Mutator<Source, Focus> get setter;
}
