{ lib
, fetchpatch
, buildGoModule
, fetchFromGitHub
, dante
, go
, ncurses
, perl
, python3
, scdoc
, w3m
}:
let
  rev = "83e7c7661dfe42e75641d764d713d144c2d7c6ce";

  libvterm = fetchFromGitHub {
    owner = "ddevault";
    repo = "go-libvterm";
    rev = "b7d861da381071e5d3701e428528d1bfe276e78f";
    sha256 = "06vv4pgx0i6hjdjcar4ch18hp9g6q6687mbgkvs8ymmbacyhp7s6";
  };
in
buildGoModule {
  pname = "aerc";
  version = "unstable-2020-05-23";

  src = fetchTarball {
    url = "https://git.sr.ht/~sircmpwn/aerc/archive/${rev}.tar.gz";
    sha256 = "15ckz7rw39v6xydg9l473fd35cflm6pfh2xb0v5hi0m2p2wvi1ai";
  };

  vendorSha256 = "1rqn36510m0yb7k4bvq2hgirr3z8a2h5xa7cq5mb84xsmhvf0g69";

  overrideModAttrs = ({ ... }: {
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
    (fetchpatch {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/cb8aa201e26551b2d6d9c2d11b4f9bbf593ac129/pkgs/applications/networking/mailreaders/aerc/runtime-sharedir.patch";
      sha256 = "1m3mx2cp8w735hb5j712y2s9a0mvvi7w14gmysy7cxk88lfgs46i";
    })
  ];

  pythonPath = [
    python3.pkgs.colorama
  ];

  buildInputs = [
    python3
  ];

  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
    wrapPythonProgramsIn $out/share/aerc/filters "$out $pythonPath"
  '';

  postFixup = ''
    wrapProgram $out/bin/aerc --prefix PATH ":" \
      "$out/share/aerc/filters:${lib.makeBinPath [ ncurses ]}"
    wrapProgram $out/share/aerc/filters/html --prefix PATH ":" \
      ${lib.makeBinPath [ w3m dante ]}
  '';
}
