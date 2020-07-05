{ stdenv
, fetchFromGitHub
, autoconf
, automake
, gettext
, intltool
, libtool
, pkgconfig
, wrapGAppsHook
, wrapPython
, gobjectIntrospection
, gtk3
, python
, pygobject3
, hicolor-icon-theme
, pyxdg

, withRandr ? stdenv.isLinux
, libxcb
, withDrm ? stdenv.isLinux
, libdrm
, withWayland ? stdenv.isLinux
, wayland
, wayland-protocols
, wlroots
, withGeoclue ? stdenv.isLinux
, geoclue
}:
let
  version = "7da875d34854a6a34612d5ce4bd8718c32bec804";
in
stdenv.mkDerivation {
  pname = "redshift";
  inherit version;

  src = fetchFromGitHub {
    owner = "minus7";
    repo = "redshift";
    rev = version;
    sha256 = "0nbkcw3avmzjg1jr1g9yfpm80kzisy55idl09b6wvzv2sz27n957";
  };

  patches = [
    # https://github.com/jonls/redshift/pull/575
    ./575.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    intltool
    libtool
    pkgconfig
    wrapGAppsHook
    wrapPython
  ];

  configureFlags = [
    "--enable-randr=${if withRandr then "yes" else "no"}"
    "--enable-geoclue2=${if withGeoclue then "yes" else "no"}"
    "--enable-drm=${if withDrm then "yes" else "no"}"
    "--enable-wayland=${if withWayland then "yes" else "no"}"
  ];

  buildInputs = [
    gobjectIntrospection
    gtk3
    python
    hicolor-icon-theme
  ] ++ stdenv.lib.optional withRandr libxcb
  ++ stdenv.lib.optional withGeoclue geoclue
  ++ stdenv.lib.optional withDrm libdrm
  ++ stdenv.lib.optionals withWayland [ wayland wayland-protocols wlroots ]
  ;

  pythonPath = [ pygobject3 pyxdg ];

  preConfigure = "./bootstrap";

  postFixup = "wrapPythonPrograms";

  # the geoclue agent may inspect these paths and expect them to be
  # valid without having the correct $PATH set
  postInstall = ''
    substituteInPlace $out/share/applications/redshift.desktop \
      --replace 'Exec=redshift' "Exec=$out/bin/redshift"
    substituteInPlace $out/share/applications/redshift.desktop \
      --replace 'Exec=redshift-gtk' "Exec=$out/bin/redshift-gtk"
  '';

  enableParallelBuilding = true;
}
