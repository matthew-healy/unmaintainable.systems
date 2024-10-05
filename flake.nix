{
  description = "The unmaintainable.systems flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            nixpkgs-fmt.enable = true;
            cspell = {
              enable = true;
              files = "(.*)\.md$";
            };
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${pre-commit.shellHook}
          '';

          nativeBuildInputs = with pkgs; [
            idris2
            idris2Packages.idris2Lsp
          ];
        };
      }
    );
}
