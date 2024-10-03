{
  inputs = rec {
    # typed-fsm seems using ghc9.10
    nixpkgs-unstable = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs =
    inputs@{
      self,
      nixpkgs-unstable,
      flake-parts,
      haskell-flake,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem =
        {
          self',
          pkgs,
          config,
          ...
        }:
        {
          haskellProjects.ghc9101 = {
            basePackages = pkgs.haskell.packages.ghc9101;
          };

          haskellProjects.default = {
            # The base package set representing a specific GHC version.
            # By default, this is pkgs.haskellPackages.
            # You may also create your own. See https://community.flake.parts/haskell-flake/package-set
            basePackages = config.haskellProjects.ghc965.outputs.finalPackages;
            packages = {
            };
            settings = {
            };
            devShell = {
            };
          };

          packages.default = self'.packages.typed-fsm;
        };
    };
}
