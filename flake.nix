{
  description = "The unmaintainable.systems flake";

  nixConfig = {
    extra-substitutors = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          haskellNix.overlay
          (final: prev: {
            unmaintainableSystems = final.haskell-nix.project' {
              src = ./generator;
              compiler-nix-name = "ghc948";
              modules = [{ doHaddock = false; }];
              shell.buildInputs = [
                generator
              ];
              shell = {
                shellHook = ''
                  ${pre-commit.shellHook}
                '';

                tools = {
                  cabal = "latest";
                  hlint = "latest";
                  haskell-language-server = "latest";
                };
              };
            };
          })
        ];

        pkgs = import nixpkgs {
          inherit overlays system;
          inherit (haskellNix) config;
        };

        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            nixpkgs-fmt.enable = true;
            ormolu.enable = true;
            cspell = {
              enable = true;
              files = "(.*)\.md$";
            };
          };
        };

        flake = pkgs.unmaintainableSystems.flake { };

        executable = "generator:exe:generator";

        generator = flake.packages.${executable};

        website = pkgs.stdenv.mkDerivation {
          name = "unmaintainable.systems";
          buildInputs = [ ];
          src = pkgs.nix-gitignore.gitignoreSourcePure [
            ./.gitignore
            ".git"
            ".github"
          ] ./.;

          LANG = "en_GB.UTF-8";
          LOCALE_ARCHIVE = pkgs.lib.optionalString
            (pkgs.buildPlatform.libc == "glibc")
            "${pkgs.glibcLocales}/lib/locale/locale-archive";

          buildPhase = ''
            ${generator}/bin/generator build --verbose
          '';

          installPhase = ''
            mkdir -p "$out/dist"
            cp -a dist/. "$out/dist"
          '';
        };
      in
      flake // {
        apps.default = flake-utils.lib.mkApp {
          drv = generator;
          exePath = "/bin/generator";
        };

        packages = {
          inherit generator website;
          default = website;
        };
      }
    );
}
