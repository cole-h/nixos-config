{ stdenv
, lib
, fetchFromGitea
, pkg-config
, meson
, ninja
, wayland-scanner
, wayland
, pixman
, wayland-protocols
, libxkbcommon
, scdoc
, tllist
, fcft
, enableCairo ? true
, withPNGBackend ? "libpng"
, withSVGBackend ? "librsvg"
  # Optional dependencies
, cairo
, librsvg
, libpng
}:

stdenv.mkDerivation rec {
  pname = "fuzzel";
  version = "2021-11-08-unstable";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "dnkl";
    repo = "fuzzel";
    rev = "817daecee60041ab18c36e8b068d915d73e3147e";
    sha256 = "sha256-BCyqwS8Ev7Gy78dp4FZZnDAW7feJHz/hchYMduhTCVw=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    meson
    ninja
    scdoc
  ];

  buildInputs = [
    wayland
    pixman
    wayland-protocols
    libxkbcommon
    tllist
    fcft
  ] ++ lib.optional enableCairo cairo
  ++ lib.optional (withPNGBackend == "libpng") libpng
  ++ lib.optional (withSVGBackend == "librsvg") librsvg;

  mesonBuildType = "release";

  mesonFlags = [
    "-Denable-cairo=${if enableCairo then "enabled" else "disabled"}"
    "-Dpng-backend=${withPNGBackend}"
    "-Dsvg-backend=${withSVGBackend}"
  ];

  meta = with lib; {
    description = "Wayland-native application launcher, similar to rofi’s drun mode";
    homepage = "https://codeberg.org/dnkl/fuzzel";
    license = licenses.mit;
    maintainers = with maintainers; [ fionera polykernel ];
    platforms = with platforms; linux;
    changelog = "https://codeberg.org/dnkl/fuzzel/releases/tag/${version}";
  };
}
