{ stdenv
, fetchFromGitHub
, qtbase
, python3
, ffmpeg
}:
let
  version = "402";
in
stdenv.mkDerivation {
  pname = "hydrus";
  inherit version;

  src = fetchFromGitHub {
    owner = "hydrusnetwork";
    repo = "hydrus";
    rev = "v${version}";
    sha256 = "00v16g2vsjag256fs0bgsg7qrg88g3f8vvfhc8xbadjxr04fizda";
  };

  nativeBuildInputs = [
    python3.pkgs.wrapPython
  ];

  pythonPath = with python3.pkgs; [
    beautifulsoup4
    html5lib
    lz4
    numpy
    opencv4
    pillow
    psutil
    pyopenssl
    pyqt5
    pyyaml
    qtpy
    requests
    send2trash
    service-identity
    twisted
    urllib3
  ];

  dontBuild = true;
  dontWrapQtApps = true;

  postPatch = ''
    sed "s@FFMPEG_PATH = os.path.join( HC.BIN_DIR, 'ffmpeg' )@FFMPEG_PATH = '${ffmpeg}/bin/ffmpeg'@" \
      -i hydrus/core/HydrusVideoHandling.py
  '';

  installPhase = ''
    mkdir -p $out/share/hydrus

    mv client.py hydrus-client
    mv server.py hydrus-server
    chmod +x hydrus-client hydrus-server
    cp -r help hydrus static hydrus-client hydrus-server $out/share/hydrus

    wrapPythonProgramsIn "$out/share/hydrus" "$out $pythonPath"

    makeWrapper $out/share/hydrus/hydrus-client $out/bin/hydrus-client \
      --add-flags '--db_dir ''${XDG_DATA_HOME:-$HOME/.local/share}/hydrus/db' \
      --prefix QT_PLUGIN_PATH : ${qtbase}/${qtbase.qtPluginPrefix}

    makeWrapper $out/share/hydrus/hydrus-server $out/bin/hydrus-server \
      --add-flags '--db_dir ''${XDG_DATA_HOME:-$HOME/.local/share}/hydrus/db' \
      --prefix QT_PLUGIN_PATH : ${qtbase}/${qtbase.qtPluginPrefix}
  '';
}
