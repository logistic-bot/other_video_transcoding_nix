{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: 
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.ffmpeg-full
          pkgs.mkvtoolnix-cli
          pkgs.ruby
        ];
      };
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "other-transcode";
        version = "0.12.0-unstable-2024-07-14";
        src = ./other-transcode.rb;
        dontUnpack = true;
        buildInputs = [pkgs.ruby pkgs.ffmpeg-full pkgs.mkvtoolnix-cli];
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/other-transcode
        '';
      };
    }
  );
}
