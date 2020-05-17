final: super:
with super;
let
  sources = import ../nix/sources.nix;
  gitignoreSource = (callPackage sources.gitignore { }).gitignoreSource;
in
{
  # https://gsc.io/content-addressed/73a9d19d65beca359dbf7f3f8f11f87f6bb227c364f8e36d7915ededde275bf4.nix
  # Thanks Graham
  emacs26 = enableDebugging (
    emacs26.overrideAttrs (
      { buildInputs, nativeBuildInputs ? [ ], configureFlags ? [ ], ... }:
      {
        src = gitignoreSource ../drvs/pgtk-emacs;

        patches = [ ];
        buildInputs = buildInputs ++ [ wayland wayland-protocols ];
        nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook texinfo ];

        configureFlags = configureFlags ++ [ "--without-x" "--with-cairo" "--with-modules" ];
      }
    )
  );
}
