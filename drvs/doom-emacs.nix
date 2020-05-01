{ stdenv
, callPackage
}:
let
  sources = import ../nix/sources.nix;
  gitignoreSource = (callPackage sources.gitignore {}).gitignoreSource;
in
stdenv.mkDerivation {
  pname = "doom-emacs";
  version = "git";

  src = gitignoreSource ./doom-emacs; # git submodule :)

  outputs = [ "out" "bin" ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/doom-emacs
    cp -r $src/* $out/share/doom-emacs

    mkdir -p $bin/bin
    ln -s $src/bin/doom $bin/bin/doom
  '';
}
