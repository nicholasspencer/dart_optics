typedef Accessor<Source, Focus> = Focus Function(Source source);

typedef Mutator<Source, Focus> = Source Function(
  Source source,
  Focus value,
);

typedef CompoundOpticFactory<Focus, Refocus> = Optical<Focus, Refocus> Function(
  Focus focus,
);

mixin Optical<Source, Focus> {
  Accessor<Source, Focus> get getter;

  Mutator<Source, Focus> get setter;
}
