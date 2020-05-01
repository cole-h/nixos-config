{ lib
, buildPackage # from naersk
, fzf
, git
}:
buildPackage {
  pname = "zoxide";
  version = "0.3.1";

  root = lib.cleanSourceWith {
    src = toString ~/workspace/vcs/zoxide;
    filter = name: type: let baseName = baseNameOf (toString name); in !(
      # Filter out version control software files/directories
      (type == "directory" && baseName == "target")
      || # Filter out nix-build result symlinks
      (type == "symlink" && lib.hasPrefix "result" baseName)
    );
  };

  cargoOptions = (opts: opts ++ [ "--locked" ]);

  postPatch = ''
    sed -i 's@"])@", "--dirty="])@' \
      build.rs
  '';

  buildInputs = [ fzf ];

  override = (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
    }
  );
}
