{ lib
, stdenv
, writeText
, rustPlatform
, fetchFromGitHub
, pkg-config
, protobuf
, makeWrapper
, dbus
, libnftnl
, libmnl
, libwg
}:
let
  # result of running address_cache as of 27 Jan 2022
  bootstrap-address-cache = writeText "api-ip-address.txt" ''
    193.138.218.78:443
    193.138.218.71:444
    185.65.134.66:444
    185.65.135.117:444
    217.138.254.130:444
    91.90.44.10:444
  '';
in
rustPlatform.buildRustPackage rec {
  pname = "mullvad";
  version = "2022.1-beta1";

  src = fetchFromGitHub {
    owner = "mullvad";
    repo = "mullvadvpn-app";
    rev = version;
    sha256 = "sha256-s/gKItWyzb/5JhxHhc3nBRQ3B36QEDQBS+hF/nYakhc=";
  };

  cargoSha256 = "sha256-HMUjB9Gq73zB2yYvvYe+/l/8SQuCilG6yMJlr2qk09Y=";

  nativeBuildInputs = [
    pkg-config
    protobuf
    makeWrapper
  ];

  buildInputs = [
    dbus.dev
    libnftnl
    libmnl
  ];

  # talpid-core wants libwg.a in build/lib/{triple}
  preBuild = ''
    dest=build/lib/${stdenv.targetPlatform.config}
    mkdir -p $dest
    ln -s ${libwg}/lib/libwg.a $dest
  '';

  postFixup =
    # Place all binaries in the 'mullvad-' namespace, even though these
    # specific binaries aren't used in the lifetime of the program.
    # `address_cache` is used to generate the `api-ip-address.txt` file, which
    # contains list of Mullvad API servers -- though we provide a "backup" of
    # the output of this command, it could change at any time, so we want
    # users to be able to regenerate the list at any time. (The daemon will
    # refuse to start without this file.)
    ''
      for bin in address_cache relay_list translations-converter; do
        mv "$out/bin/$bin" "$out/bin/mullvad-$bin"
      done
    '' +
    # Put distributed assets in-place -- specifically, the
    # bootstrap-address-cache is necessary; otherwise, the user will have to run
    # the `address_cache` binary and move the contents into place at
    # /var/cache/mullvad-vpn/api-ip-address.txt manually. It is unknown at this
    # time whether the `ca.crt` is also necessary.
    ''
      mkdir -p $out/share
      ln -s ${bootstrap-address-cache} $out/share/api-ip-address.txt
      cp dist-assets/ca.crt $out/share
    '' +
    # Set the directory where Mullvad will look for its resources by default to
    # `$out/share`, so that we can avoid putting the files in `$out/bin` --
    # Mullvad defaults to looking inside the directory its binary is located in
    # for its resources.
    ''
      wrapProgram $out/bin/mullvad-daemon \
        --set MULLVAD_RESOURCE_DIR "$out/share"
    '';

  meta = with lib; {
    description = "Mullvad VPN command-line client tools";
    homepage = "https://github.com/mullvad/mullvadvpn-app";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ cole-h ];
  };
}
