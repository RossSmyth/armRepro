{
  lib,
  stdenv,
  meson,
  ninja,

  mesFlags ? [ "--cross-file=./arm-none-eabi-gcc.ini" ],
}:
let
  fs = lib.fileset;
  files = fs.intersection (fs.gitTracked ./.) (
    fs.unions [
      ./meson.build
      ./arm-none-eabi-gcc.ini
      ./src
    ]
  );
in
stdenv.mkDerivation (self: {
  name = "reproducer";

  src = fs.toSource {
    root = ./.;
    fileset = files;
  };

  strictDeps = true;
  depsBuildBuild = [
    meson
    ninja
  ];

  mesonFlags = mesFlags;

  hardeningDisable = [ "all" ];
})
