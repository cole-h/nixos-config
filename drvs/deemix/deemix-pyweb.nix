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
      version = "1.2.15";
    in
    buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit pname version;
        sha256 = "1hw8f2yspzac7ki8nyib006n0wnf5xblxhcczargh6dfq7i6kg6d";
      };

      # Accesses the network.
      dontUseSetuptoolsCheck = true;

      propagatedBuildInputs = with python3.pkgs; [
        click
        requests
        pycryptodomex
        mutagen
        (spotipy.overridePythonAttrs ({ ... }: { dontUseSetuptoolsCheck = true; }))
      ];
    };

  # fuck
  flask-socketio = python3.pkgs.flask-socketio.overridePythonAttrs ({ ... }: {
    propagatedBuildInputs = with python3.pkgs; [
      flask
      # fuCK
      (python-socketio.overridePythonAttrs ({ ... }: {
        propagatedBuildInputs = with python3.pkgs; [
          six
          # FUCK
          (python-engineio.overridePythonAttrs ({ ... }: { dontUseSetuptoolsCheck = true; }))
        ];
      }))
    ];
  });

in
stdenv.mkDerivation {
  pname = "deemix-pyweb";
  version = "git";

  src = fetchgit {
    url = "https://codeberg.org/RemixDev/deemix-pyweb.git";
    rev = "c83e9a459e373f5e1441c54475d7c2d96145eb0d";
    sha256 = "0g8rpnwc8p5v5jgx1rr2gyzvr572ganw5qk2v367nwjs4x34j0hs";
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
  ] ++ [
    deemix
    flask-socketio
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
