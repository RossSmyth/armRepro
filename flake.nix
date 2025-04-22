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
          config = "armv6m-none-eabi";
          gcc = {
            float-abi = "softfp";
          };
        };
      };

      firmware = pkgsCross.callPackage ./. { };
    in
    {
      packages.${system}.default = firmware;
    };

}
