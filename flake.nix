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
      packages.default = 
        let
          pname = "other-transcode";
          version = "0.12.0-unstable-2024-07-14";
          my-buildInputs = [pkgs.ruby pkgs.ffmpeg-full pkgs.mkvtoolnix-cli];
          script-unwrapped = pkgs.stdenv.mkDerivation {
            pname = "${pname}-unwrapped";
            inherit version;
            src = ./other-transcode.rb;
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/${pname}
            '';
          };
        in pkgs.symlinkJoin {
          name = pname;
          paths = [ script-unwrapped ] ++ my-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${pname} --prefix PATH : $out/bin";
        };
    }
  );
}
