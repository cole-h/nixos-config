{ stdenv
, fetchFromGitHub
, meson
, ninja
, gettext
, pkgconfig
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

stdenv.mkDerivation rec {
  pname = "foliate";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    sha256 = "1dhhy2fh1rc11qp8vgypxrr1dflh9vpjn4v3ci4fzrhwamzllpmx";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    hicolor-icon-theme
    meson
    ninja
    pkgconfig
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
    ln -s "$out/bin/com.github.johnfactotum.Foliate" "$out/bin/foliate"

    sed -e "2iimports.package._findEffectiveEntryPointName = () => 'com.github.johnfactotum.Foliate'" \
      -i $out/bin/foliate
  '';
}
