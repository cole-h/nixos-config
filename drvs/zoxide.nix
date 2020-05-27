{ lib
, buildPackage # from naersk
, fzf
, git
}:
buildPackage {
  pname = "zoxide";
  version = "0.4.0-git";

  root = lib.cleanSource ~/workspace/vcs/zoxide;

  cargoOptions = (opts: opts ++ [ "--locked" ]);

  postPatch = ''
    sed -i 's@"])@", "--dirty="])@' \
      build.rs
  '';

  buildInputs = [ fzf ];

  override = ({ nativeBuildInputs ? [ ], ... }: {
    nativeBuildInputs = nativeBuildInputs ++ [ git ];
  });
}
