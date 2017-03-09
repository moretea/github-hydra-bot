with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "github-hydra-bot-env";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in
{
  github-hydra-bot = stdenv.mkDerivation rec {
    name = "github-hydra-bot";
    buildInputs = [ ruby env];
    src = ./.;
    buildCommand = ''
      mkdir -p $out/bin
      cat <<EOF >$out/bin/github-hydra-bot
      #!${pkgs.bash}/bin/bash
      ${pkgs.ruby}/bin/ruby ${src}/exe/github-hydra-bot
      EOF
      chmod +x $out/bin/github-hydra-bot
    '';
  };
}
