final: super:
with super;
let
  sources = import ../nix/sources.nix;
  gitignoreSource = (callPackage sources.gitignore { }).gitignoreSource;
in
{
  emacs26 =
    enableDebugging
      (emacs26.overrideAttrs
        (
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
