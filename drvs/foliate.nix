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
  # , hyphen
}:

stdenv.mkDerivation rec {
  pname = "foliate";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    sha256 = "1n5h6vbjys44f42wgsdalzyv95pybrg1q4nzbgvx78c17crlivaw";
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
    # TODO: Add once packaged, unclear how language packages best handled
    # hyphen
  ];

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  # Kludge so gjs can find resources by using the unwrapped name
  # Improvements/alternatives welcome, but this seems to work for now :/.
  # See: https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
  postInstall = ''
    sed -e "2iimports.package._findEffectiveEntryPointName = () => 'com.github.johnfactotum.Foliate'" \
      -i $out/bin/com.github.johnfactotum.Foliate

    mv "$out/bin/com.github.johnfactotum.Foliate" "$out/bin/foliate"
  '';

  meta = with stdenv.lib; {
    description = "Simple and modern GTK eBook reader";
    homepage = "https://johnfactotum.github.io/foliate/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dtzWill ];
  };
}
