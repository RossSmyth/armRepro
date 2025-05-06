{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      pkgsCross = import nixpkgs {
        localSystem = pkgs.stdenv.buildPlatform;
        crossSystem = {
          config = "arm-none-eabi";
          # gcc-arm-embedded has bundled libcs, so we will pass that in ourselves.
          libc = null;
          gcc = {
            thumb = true;
            cpu = "cortex-m0";
            float-abi = "softfp";
            arch = "armv6-m";
          };
        };
      };

      stdenv = pkgsCross.overrideCC pkgsCross.stdenv (pkgsCross.wrapCCWith {
        nativeTools = false;
        coreutils = pkgs.coreutils;
        name = "embedded-wrapped";
        noLibc = true;
        cc = pkgs.gcc-arm-embedded;
        bintools = pkgs.wrapBintoolsWith {
          nativeTools = false;
          coreutils = pkgs.coreutils;
          noLibc = true;
          libc = null;
          bintools = pkgs.gcc-arm-embedded;
          isGNU = true;
        };
        libc = null;
        # Use newlib-nano
        nixSupport.cc-cflags = [
          "-specs=nano.specs"
        ];
      });
      firmware = pkgsCross.callPackage ./. { inherit stdenv; };
    in
    {
      packages.${system} = {
        default = firmware;
        cc = stdenv.cc;
      };
    };

}
