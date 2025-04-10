{
  lib,
  stdenv,
  fetchFromGitea,
  alsa-lib,
  bison,
  fcft,
  flex,
  json_c,
  libmpdclient,
  libyaml,
  meson,
  ninja,
  pipewire,
  pixman,
  pkg-config,
  pulseaudio,
  scdoc,
  tllist,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xcbutil,
  xcbutilcursor,
  xcbutilerrors,
  xcbutilwm,
  waylandSupport ? true,
  x11Support ? true,
}:

assert (x11Support || waylandSupport);
stdenv.mkDerivation (finalAttrs: {
  pname = "yambar";
  version = "0-unstable-2025-03-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "dnkl";
    repo = "yambar";
    rev = "43e19446071c49016d571bdb432e1a6e1e1e8778";
    hash = "sha256-erWbwhVj97JGdxwnPICmwAM2GeWyqUteI0VPhqzKWt4=";
  };

  patches = [
    ./spawn-on-specific-monitor.diff
  ];

  outputs = [
    "out"
    "man"
  ];

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs =
    [
      alsa-lib
      fcft
      json_c
      libmpdclient
      libyaml
      pipewire
      pixman
      pulseaudio
      tllist
      udev
    ]
    ++ lib.optionals (waylandSupport) [
      wayland
      wayland-protocols
    ]
    ++ lib.optionals (x11Support) [
      xcbutil
      xcbutilcursor
      xcbutilerrors
      xcbutilwm
    ];

  strictDeps = true;

  mesonBuildType = "release";

  mesonFlags = [
    (lib.mesonBool "werror" false)
    (lib.mesonEnable "backend-x11" x11Support)
    (lib.mesonEnable "backend-wayland" waylandSupport)
  ];
})

