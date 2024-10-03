{
  inputs = rec {
    # typed-fsm seems using ghc9.10
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    mylib.url = "git+file:///home/nixos/mylib";
    typed-fsm.url = "git+file:///home/nixos/fix/typed-fsm";
    typed-fsm.flake = false;
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-parts,
      haskell-flake,
      mylib,
      typed-fsm,
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
            let pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux.extend mylib.overlay.default;
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
            # The base package set representing a specific GHC version.
            # By default, this is pkgs.haskellPackages.
            # You may also create your own. See https://community.flake.parts/haskell-flake/package-set
            basePackages = config.haskellProjects.ghc9101.outputs.finalPackages;
           devShell = {
            };
          };

          packages.default = self'.packages.examples;
        };
    };
}
