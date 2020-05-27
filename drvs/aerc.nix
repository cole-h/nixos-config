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
  rev = "6c4ed3cfe2fe66a1e5f26c404ea90e048142db72";
  vendorSha256 = "0p6bm34qk1kmw47lk0k8gl8mz091bvm0lc51m2v28xih58mmp70b";
  sha256 = "1bcvwnvk20qj3dm3ajkbfcsq6662ipq4n1gsbp10dn384xwxbw7j";

  libvterm = fetchFromGitHub {
    owner = "ddevault";
    repo = "go-libvterm";
    rev = "b7d861da381071e5d3701e428528d1bfe276e78f";
    sha256 = "06vv4pgx0i6hjdjcar4ch18hp9g6q6687mbgkvs8ymmbacyhp7s6";
  };
in
buildGoModule {
  pname = "aerc";
  version = "unstable-2020-05-26";

  src = fetchTarball {
    url = "https://git.sr.ht/~sircmpwn/aerc/archive/${rev}.tar.gz";
    inherit sha256;
  };

  inherit vendorSha256;

  overrideModAttrs = ({ ... }: {
    postBuild = ''
      # cp -r --reflink=auto ${libvterm}/libvterm vendor/github.com/ddevault/go-libvterm
      # cp -r --reflink=auto ${libvterm}/encoding vendor/github.com/ddevault/go-libvterm
      cp -r --reflink=auto ${libvterm}/* vendor/github.com/ddevault/go-libvterm
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
