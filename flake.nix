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
          packages.loss-run-events = pkgs.haskellPackages.loss-run-events;
          packages.default = pkgs.lib.trivial.pipe pkgs.haskellPackages.loss-run-events
            [
              hl.dontHaddock
              hl.enableStaticLibraries
              hl.justStaticExecutables
              hl.disableLibraryProfiling
              hl.disableExecutableProfiling
            ];

          checks = {
            inherit (pkgs.haskellPackages) loss-run-events;
          };

          devShells.default = pkgs.haskellPackages.shellFor {
            packages = p: [ p.loss-run-events ];
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
            loss-run-events =
              let
                haskellSourceFilter = prev.lib.sourceFilesBySuffices ./. [
                  ".cabal"
                  ".hs"
                ];
              in
              hprev.callCabal2nix "loss-run-events" haskellSourceFilter { };
          });
        };
      };
    };
}
