{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    glfw
    libepoxy.out
    libepoxy.dev
  ];
  nativeBuildInputs = [ pkgs.zig ];
}
