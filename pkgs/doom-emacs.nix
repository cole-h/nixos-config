{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "doom-emacs";
  version = "git-20200224";

  # TODO: clone doom-emacs if it doesn't exist
  src = ./doom-emacs;

  outputs = [ "out" "bin" ];

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/doom-emacs
    cp -r $src/* $out/share/doom-emacs

    mkdir -p $bin/bin
    ln -s $src/bin/doom $bin/bin/doom
  '';
}
