{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [ 
        swiProlog
        ghc
        gcc
        gnumake
    ];
}
