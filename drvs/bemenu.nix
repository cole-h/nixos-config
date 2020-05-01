{ stdenv
, lib
, fetchFromGitHub
, cairo
, libxkbcommon
, pango
, fribidi
, harfbuzz
, pcre
, pkgconfig
, ncursesSupport ? false
, ncurses ? null
, waylandSupport ? true
, wayland ? null
, wayland-protocols ? null
, x11Support ? false
, xlibs ? null
, xorg ? null
}:

assert ncursesSupport -> ncurses != null;
assert waylandSupport -> wayland != null && wayland-protocols != null;
assert x11Support -> xlibs != null && xorg != null;

stdenv.mkDerivation rec {
  pname = "bemenu";
  version = "2020-03-19";

  src = fetchFromGitHub {
    owner = "Cloudef";
    repo = pname;
    rev = "cd53b7bb555cf1c5afaae3779a88e126571faf8c";
    sha256 = "0hkv9w5zka5sjby3qhkjip5h9xhah4ay5sf2bzwmiffyldcg2gml";
  };

  nativeBuildInputs = [
    pkgconfig
    pcre
  ];

  buildInputs = with lib; [
    cairo
    fribidi
    harfbuzz
    libxkbcommon
    pango
  ] ++ optionals ncursesSupport [
    ncurses
  ]
  ++ optionals waylandSupport [
    wayland
    wayland-protocols
  ]
  ++ optionals x11Support [
    xlibs.libX11
    xlibs.libXinerama
    xlibs.libXft
    xorg.libXdmcp
    xorg.libpthreadstubs
    xorg.libxcb
  ];

  PREFIX = placeholder "out";

  buildPhase = ''
    make clients ${lib.optionalString ncursesSupport "curses"} \
      ${lib.optionalString x11Support "x11"} ${lib.optionalString waylandSupport "wayland"}
  '';

  installPhase = ''
    mkdir -p $out
    make install
  '';
}
