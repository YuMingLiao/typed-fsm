{
  inputs = rec {
    # typed-fsm seems using ghc9.10
    typed-fsm.url = "github:YuMingLiao/typed-fsm";
    common.follows = "typed-fsm/common";
    nixpkgs.follows = "common/nixpkgs";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      typed-fsm,
      common,
      ...
    }:
    common.lib.mkFlake { inherit inputs; } {
      perSystem =
        {
          self',
          pkgs,
          config,
          ...
        }:
        {
          haskellProjects.default = {
            packages = {
              typed-fsm.source = typed-fsm;
              th-desugar.source = "1.17";
              singletons-th.source = "3.4";
              singletons-base.source = "3.4";
            };
            settings = {
              sdl2.jailbreak = true;
            };
 
            basePackages = config.haskellProjects.ghc9101.outputs.finalPackages;
            projectRoot = with common.inputs.nixpkgs.lib.fileset;
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
