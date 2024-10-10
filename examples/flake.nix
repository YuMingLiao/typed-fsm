{
  inputs = rec {
    # typed-fsm seems using ghc9.10
    nixpkgs-unstable.follows = "common/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    typed-fsm.url = "github:YuMingLiao/typed-fsm";
    common.url = "github:YuMingLiao/common";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-parts,
      haskell-flake,
      typed-fsm,
      common,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs-unstable.lib.systems.flakeExposed;
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
            let pkgs = common.legacyPackages.x86_64-linux;
            in
            with pkgs.haskell.lib;
            with pkgs.lib.trivial;
            {
            basePackages = pipe pkgs.haskell.packages.ghc9101 [noHaddocks noChecks];
            packages = {
              typed-fsm.source = typed-fsm;
              th-desugar.source = "1.17";
              singletons-th.source = "3.4";
              singletons-base.source = "3.4";
            };
            settings = {
              sdl2.jailbreak = true;
            };
 
          };

          haskellProjects.default = {
            basePackages = config.haskellProjects.ghc9101.outputs.finalPackages;
            projectRoot = with nixpkgs-unstable.lib.fileset;
              builtins.toString( toSource {
                root = ./.;
                fileset = unions [
                  ./ATM
                  ./data
                  ./examples.cabal
                  ./motion
                  ./turnstile
                  ./CHANGELOG.md
                  ./LICENSE
                ];
                #difference ./. (maybeMissing ./result);
              });
           devShell = {
            };
          };

          packages.default = self'.packages.examples;
        };
    };
}
