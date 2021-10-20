{ stdenv
, fetchFromGitHub
, meson
, ninja
, gettext
, pkg-config
, python3
, wrapGAppsHook
, gobject-introspection
, gjs
, gtk3
, gsettings-desktop-schemas
, webkitgtk
, gdk-pixbuf
, glib
, glib-networking
, desktop-file-utils
, hicolor-icon-theme /* setup hook */
, libarchive
}:
let
  version = "2.6.2";
  pname = "foliate";
  sha256 = "sha256-hfvZMzNACk8ECnrCfQ8WSTbqVcNhmboOCKNGSkxBwAM=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    hicolor-icon-theme
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    gdk-pixbuf
    gjs
    glib
    glib-networking # for online dictionary support
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    libarchive
    webkitgtk
  ];

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  # Kludge so gjs can find resources by using the unwrapped name
  # Improvements/alternatives welcome, but this seems to work for now :/
  # See: https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
  postInstall = ''
    sed -e "2iimports.package._findEffectiveEntryPointName = () => 'com.github.johnfactotum.Foliate'" \
      -i $out/bin/com.github.johnfactotum.Foliate
  '';

  postFixup = ''
    ln -s "$out/bin/com.github.johnfactotum.Foliate" "$out/bin/foliate"
  '';
}
