{ pkgs ? import <nixpkgs> { } }:

{
  buildInputs = [ pkgs.raylib ];
  nativeBuildInputs = [ pkgs.zig ];
}
