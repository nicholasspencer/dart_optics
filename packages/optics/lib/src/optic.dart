typedef Accessor<Source, Focus> = Focus Function(Source source);

typedef Mutator<Source, Focus> = Source Function(
  Source source,
  Focus value,
);

typedef CompoundOpticFactory<Focus, Refocus> = Optic<Focus, Refocus> Function(
  Focus focus,
);

mixin Optic<Source, Focus> {
  Accessor<Source, Focus> get getter;

  Mutator<Source, Focus> get setter;

  // Optic<Source, Refocus> compoundWithOptic<Refocus>(
  //   Optic<Focus, Refocus> lens,
  // );

  // Optic<Source, Refocus> compoundWithFocusFactory<Refocus>(
  //   CompoundOpticFactory<Focus, Refocus> factory,
  // );
}
