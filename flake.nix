{
  inputs = {
    # typed-fsm seems using ghc9.10, thus nixpkgs-unstable
    common.url = "github:YuMingLiao/common";
    nixpkgs.follows = "common/nixpkgs";
  };
  outputs =
    inputs@{
      self,
      common,
      ...
    }:
    common.lib.mkFlake { inherit inputs; } {
      perSystem =
        {
          self',
          config,
          pkgs,
          ...
        }:
        {
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
