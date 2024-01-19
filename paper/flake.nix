{
  description = "Build the document";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        texlive = pkgs.texlive.combined.scheme-full;
      in {
        packages.comp-trace = pkgs.stdenvNoCC.mkDerivation {
          name = "comp-trace";
          buildInputs = with pkgs; [
            ghc
            gnumake
            lhs2tex
            texlive
          ];
          builder = "${pkgs.bash}/bin/bash";
          args = [ "-c" ''
            source $stdenv/setup
            mkdir -p $out
            cp -r $src/* .
            make comp-trace.pdf comp-trace-ext.pdf
            cp *.pdf $out/
          ''];
          src = ./.;
          system = "x86_64-linux";
        };

        defaultPackage = self.packages.${system}.comp-trace;

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}
