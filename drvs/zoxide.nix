{ lib
, fetchFromGitHub
, fzf
, callPackage
}:
let
  src = toString ~/workspace/vcs/zoxide;
  sources = import <vin/nix/sources.nix>;
  naersk = callPackage sources.naersk {};
  gitignoreSource = (callPackage sources.gitignore {}).gitignoreSource;
  commitHash = with lib; substring 0 8 (commitIdFromGitRepo "${src}/.git");
in
naersk.buildPackage {
  pname = "zoxide";
  version = commitHash;

  root = gitignoreSource src;
  cargoOptions = (opts: opts ++ [ "--locked" ]);

  postPatch = ''
    sed -i 's@, hash@, "-${commitHash}"@' \
      build.rs
  '';

  buildInputs = [
    fzf
  ];
}
