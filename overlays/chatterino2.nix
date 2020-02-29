final: super:
with super;

{
  chatterino2 = chatterino2.overrideAttrs (old: rec {
    version = "2.1.7";

    src = fetchFromGitHub {
      owner = "Chatterino";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "0bbdzainfa7hlz5p0jfq4y04i3wix7z3i6w193906bi4gr9wilpg";
      fetchSubmodules = true;
    };

    # NOTE: creates files in ~/.local/share/.chatterino-wrapped (or similar) now
    buildInputs = old.buildInputs ++ [ makeWrapper ];

    postInstall = old.postInstall or "" + ''
      wrapProgram $out/bin/chatterino \
        --set QT_XCB_FORCE_SOFTWARE_OPENGL 1 \
        --set QT_QPA_PLATFORM xcb
    '';
  });
}
