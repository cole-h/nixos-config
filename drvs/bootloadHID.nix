{ stdenv
, libusb-compat-0_1
}:

stdenv.mkDerivation {
  pname = "bootloadHID";
  version = "2012-12-08";

  src = fetchTarball {
    url = "https://www.obdev.at/downloads/vusb/bootloadHID.2012-12-08.tar.gz";
    sha256 = "0nzi29yiz891hsmla4dsdmqdgi38j1z5axlfngpgmig1c9kyn7k6";
  };

  nativeBuildInputs = [
    libusb-compat-0_1
  ];

  preBuild = ''
    cd commandline
  '';

  installPhase = ''
    install -D bootloadHID $out/bin/bootloadHID
  '';
}
