{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        name = "game-of-life";
        src = pkgs.lib.cleanSource ./.;
        buildInputs = [ pkgs.raylib ];
        cargoLock.lockFile = ./Cargo.lock;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.raylib ];
        nativeBuildInputs = [ pkgs.cargo pkgs.rustc ];
      };
    };
}
