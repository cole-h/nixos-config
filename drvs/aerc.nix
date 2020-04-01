{ stdenv
, buildGoModule
, fetchpatch
, go
, ncurses
, scdoc
, python3
, w3m
, dante
}:
let
  rev = "35402e21d9b75f0d0a3a4efb8b552e1c9a2e6d59";
in
buildGoModule rec {
  pname = "aerc";
  version = "unstable-2020-03-26";

  src = fetchTarball {
    url = "https://git.sr.ht/~sircmpwn/aerc/archive/${rev}.tar.gz";
    sha256 = "0xm540zcaz6f3fnp1pdc9wk8zlnksnhaqcdh51mfcm6d7biy0pcp";
  };

  modSha256 = "048jx502h7jw8ksqijz6r3dffj8v2h168za5qazva6fcn33kp0gw";

  nativeBuildInputs = [
    go
    scdoc
    python3.pkgs.wrapPython
  ];

  patches = [
    (
      fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/cb8aa201e26551b2d6d9c2d11b4f9bbf593ac129/pkgs/applications/networking/mailreaders/aerc/runtime-sharedir.patch";
        sha256 = "1m3mx2cp8w735hb5j712y2s9a0mvvi7w14gmysy7cxk88lfgs46i";
      }
    )
  ];

  pythonPath = [
    python3.pkgs.colorama
  ];

  buildInputs = [ python3 ];

  buildPhase = "
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  ";

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    wrapPythonProgramsIn $out/share/aerc/filters "$out $pythonPath"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/aerc --prefix PATH ":" \
      "$out/share/aerc/filters:${stdenv.lib.makeBinPath [ ncurses ]}"
    wrapProgram $out/share/aerc/filters/html --prefix PATH ":" \
      ${stdenv.lib.makeBinPath [ w3m dante ]}
  '';
}
