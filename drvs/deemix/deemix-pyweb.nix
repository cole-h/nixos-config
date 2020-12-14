{ stdenv
, python3
, fetchgit
, makeWrapper
}:
let
  deemix =
    let
      inherit (python3.pkgs)
        buildPythonPackage
        fetchPypi;

      pname = "deemix";
      version = "2.0.4";
    in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-Vk4p3aU/0E7cpKP7D+8VaWYqHsG5TBe8OOZgyJrig6k=";
      };

      # Accesses the network.
      dontUseSetuptoolsCheck = true;

      propagatedBuildInputs = with python3.pkgs; [
        click
        requests
        pycryptodomex
        mutagen
        (spotipy.overridePythonAttrs ({ ... }: { dontUseSetuptoolsCheck = true; }))
      ] ++ [
        deezer
      ];
    };

  deezer =
    let
      inherit (python3.pkgs)
        buildPythonPackage
        fetchPypi;

      pname = "deezer-py";
      version = "0.0.10";
    in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-PEuy4D0EKbCA/geaheZ9+RfkJdrsdpv3ny/k0QBOAz4=";
      };

      # Accesses the network.
      dontUseSetuptoolsCheck = true;

      propagatedBuildInputs = with python3.pkgs; [
        eventlet
        requests
      ];
    };

  eventlet = python3.pkgs.eventlet.overridePythonAttrs ({ ... }: {
    propagatedBuildInputs = with python3.pkgs; [
      greenlet
      monotonic
      six

      (dnspython.overridePythonAttrs ({ ... }: rec {
        pname = "dnspython";
        version = "1.16";
        src = fetchPypi {
          inherit pname version;
          extension = "zip";
          sha256 = "36c5e8e38d4369a08b6780b7f27d790a292b2b08eea01607865bf0936c558e01";
        };
      }))
    ];
  });
in
stdenv.mkDerivation {
  pname = "deemix-pyweb";
  version = "git";

  src = fetchgit {
    url = "https://git.rip/RemixDev/deemix-pyweb.git";
    rev = "521e7b02fdc4a6c2fdb6888f6424e552306711fc";
    sha256 = "sha256-Duj1XlKkCwa1duJVFGyvRdncPdjalC8Ut8qnCS+1P3o=";
    deepClone = true;
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    python3
  ];

  dontUseSetuptoolsCheck = true;

  pythonPath = with python3.pkgs; [
    pywebview
    flask
    eventlet
    flask-socketio
  ] ++ [
    deemix
    deezer
  ];

  installPhase = ''
    mkdir -p $out/bin

    sed 1d -i app.py
    chmod +x server.py

    cp server.py $out/bin/server.py
    cp app.py $out/bin/app.py
    cp -r webui $out/bin/webui

    wrapPythonProgramsIn "$out/bin" "$out $pythonPath"
    mv $out/bin/server.py $out/bin/deemix
  '';
}
