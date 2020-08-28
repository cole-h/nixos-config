{ lib
, buildGoModule
, go
, ncurses
, notmuch
, scdoc
, python3
, perl
, w3m
, dante
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "aerc";
  version = "unstable-20200727";

  src = fetchTarball {
    url = "https://git.sr.ht/~sircmpwn/aerc/archive/f81cc2803cca4a5213a9d4514ddae8417c23f8ee.tar.gz";
    sha256 = "1ralm6x6wbr46lrv0jfjl28xa06v2q1g1403b8y0ihy7caq4f44b";
  };

  libvterm = fetchFromGitHub {
    owner = "ddevault";
    repo = "go-libvterm";
    rev = "b7d861da381071e5d3701e428528d1bfe276e78f";
    sha256 = "06vv4pgx0i6hjdjcar4ch18hp9g6q6687mbgkvs8ymmbacyhp7s6";
  };

  vendorSha256 = "1yjrg8pr8l367dx3rgp3q8qgsphcbwf73cc13hz20yg8dir0jc7j";

  overrideModAttrs = (_: {
    postBuild = ''
      cp -r --reflink=auto ${libvterm}/libvterm vendor/github.com/ddevault/go-libvterm
      cp -r --reflink=auto ${libvterm}/encoding vendor/github.com/ddevault/go-libvterm
    '';
  });

  nativeBuildInputs = [
    scdoc
    python3.pkgs.wrapPython
  ];

  patches = [
    ./runtime-sharedir.patch
  ];

  pythonPath = [
    python3.pkgs.colorama
  ];

  buildInputs = [ python3 notmuch ];

  buildPhase = "
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  ";

  installPhase = ''
    runHook preInstall
    make PREFIX=$out GOFLAGS="$GOFLAGS -tags=notmuch" install
    wrapPythonProgramsIn $out/share/aerc/filters "$out $pythonPath"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/aerc --prefix PATH ":" \
      "$out/share/aerc/filters:${lib.makeBinPath [ ncurses ]}"
    wrapProgram $out/share/aerc/filters/html --prefix PATH ":" \
      ${lib.makeBinPath [ w3m dante ]}
  '';

  meta = with lib; {
    description = "aerc is an email client for your terminal";
    homepage = "https://aerc-mail.org/";
    maintainers = with maintainers; [ tadeokondrak ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
