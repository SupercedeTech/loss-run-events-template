{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };
          hl = pkgs.haskell.lib;
        in
        {
          packages.yesod-subsite = pkgs.haskellPackages.yesod-subsite;
          packages.default = pkgs.lib.trivial.pipe pkgs.haskellPackages.yesod-subsite
            [
              hl.dontHaddock
              hl.enableStaticLibraries
              hl.justStaticExecutables
              hl.disableLibraryProfiling
              hl.disableExecutableProfiling
            ];

          checks = {
            inherit (pkgs.haskellPackages) yesod-subsite;
          };

          devShells.default = pkgs.haskellPackages.shellFor {
            packages = p: [ p.yesod-subsite ];
            buildInputs = with pkgs.haskellPackages; [
              cabal-fmt
              cabal-install
              hlint
            ];
          };
        }) // {
      overlays.default = _: prev: {
        haskell = prev.haskell // {
          # override for all compilers
          packageOverrides = prev.lib.composeExtensions prev.haskell.packageOverrides (_: hprev: {
            yesod-subsite =
              let
                haskellSourceFilter = prev.lib.sourceFilesBySuffices ./. [
                  ".cabal"
                  ".hs"
                ];
              in
              hprev.callCabal2nix "yesod-subsite" haskellSourceFilter { };
          });
        };
      };
    };
}
