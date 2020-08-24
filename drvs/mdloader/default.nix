{ stdenv
, fetchFromGitHub
, substituteAll
}:

stdenv.mkDerivation {
  pname = "mdloader";
  version = "unstable-20190806";

  src = fetchFromGitHub {
    owner = "Massdrop";
    repo = "mdloader";
    rev = "caa03ede129d53ba48cdb28e11c7a6e197d595e4";
    sha256 = "0nmz90xrjk1wlgn9r8xygvr44kzx796cq3480kgg58xky7z8dgq1";
  };

  patches = [
    ./fix-stuff.diff
  ];

  postPatch = ''
    substituteInPlace mdloader_common.c --subst-var-by out ${placeholder "out"}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/* $out/bin
  '';
}
