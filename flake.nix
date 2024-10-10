{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    # typed-fsm seems using ghc9.10, thus nixpkgs-unstable
    common.url = "github:YuMingLiao/common";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      haskell-flake,
      common,
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
          haskellProjects.ghc9101 =
            let
              pkgs = common.legacyPackages.x86_64-linux;
            in
            with pkgs.haskell.lib;
            with pkgs.lib.trivial;
            {
              basePackages = pipe pkgs.haskell.packages.ghc9101 [
                noHaddocks
                noChecks
              ];
            };

          haskellProjects.default = {
            basePackages = config.haskellProjects.ghc9101.outputs.finalPackages;
            packages = {
              th-desugar.source = "1.17";
              singletons-th.source = "3.4";
              singletons-base.source = "3.4";
            };
          };

          packages.default = self'.packages.typed-fsm;
        };
    };
}
