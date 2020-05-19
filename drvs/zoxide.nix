{ lib
, buildPackage # from naersk
, fzf
, git
}:
buildPackage {
  pname = "zoxide";
  version = "0.4.0-git";

  root = lib.cleanSourceWith {
    src = toString ~/workspace/vcs/zoxide;
    filter = name: type:
      let
        baseName = baseNameOf (toString name);
      in
        !((type == "directory" && baseName == "target")
          || (type == "symlink" && lib.hasPrefix "result" baseName));
  };

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
