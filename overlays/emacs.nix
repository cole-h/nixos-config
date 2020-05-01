final: super:
with super;
{
  emacs26 =
    enableDebugging
      (emacs26.overrideAttrs
        (
          { buildInputs, configureFlags ? [ ], postPatch ? "", nativeBuildInputs ? [ ], ... }:
          {
            src = ../drvs/pgtk-emacs;

            patches = [ ];
            buildInputs = buildInputs ++ [ wayland wayland-protocols ];
            nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook texinfo ];

            configureFlags = configureFlags ++ [ "--without-x" "--with-cairo" "--with-modules" ];
          }
        )
      );
}
