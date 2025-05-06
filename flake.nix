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
          # The wrapper uses this as the target prefix, so this must be "arm-none-eabi"
          config = "arm-none-eabi";
          # gcc-arm-embedded has bundled libcs, so we will pass that in ourselves.
          libc = null;
          gcc = {
            # Need to set all these manually because of funny reasons
            thumb = true;
            cpu = "cortex-m0";
            float-abi = "softfp";
            arch = "armv6-m";
          };
        };
      };

      stdenv = pkgs.overrideCC pkgsCross.stdenv (pkgs.wrapCCWith {
        name = "embedded-wrapped";
        # Not strictly needed.
        noLibc = true;
        
        stdenvNoCC = pkgsCross.stdenvNoCC;

        # GCC is at this pkgs/bin/gcc
        cc = pkgs.gcc-arm-embedded;

        # Unsure if this is needed, but probably good to have.
        bintools = pkgs.wrapBintoolsWith {
          stdenvNoCC = pkgsCross.stdenvNoCC;
          noLibc = true;

          # Again, we will try. May need to pass the specs with some extra flags here too?
          libc = null;

          # at pkg/bin
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
        # For debugging
        cc = stdenv.cc;
      };
    };

}
