final: super:
let
  inherit (final)
    callPackage
    libsForQt5
    runCommand
    # pkgs
    ;

  sources = import ../nix/sources.nix;
  naersk = callPackage sources.naersk { };
in
{
  # fonts
  # san-francisco = callPackage ../drvs/san-francisco.nix {};
  # sarasa-gothic = callPackage ../drvs/sarasa-gothic.nix {};

  # misc
  aerc = callPackage ../drvs/aerc.nix { };
  bemenu = callPackage ../drvs/bemenu.nix { };
  chatterino2 = libsForQt5.callPackage ../drvs/chatterino2.nix { };
  doom-emacs = callPackage ../drvs/doom-emacs.nix { };
  fish = callPackage ../drvs/fish.nix { };
  foliate = callPackage ../drvs/foliate.nix { };
  gsfonts = callPackage ../drvs/gsfonts.nix { };
  iosevka-custom = callPackage ../drvs/iosevka/iosevka-custom.nix { };
  git-crypt = callPackage ../drvs/git-crypt.nix { };
  passrs = callPackage ~/workspace/langs/rust/passrs { };

  alacritty = callPackage ../drvs/alacritty.nix {
    inherit (naersk) buildPackage;
  };

  # redshift-wayland = callPackage ../drvs/redshift-wayland {
  #   inherit (pkgs.python3Packages) python pygobject3 pyxdg wrapPython;
  #   geoclue = pkgs.geoclue2;
  # };

  zoxide = callPackage ../drvs/zoxide.nix {
    inherit (naersk) buildPackage;
  };

  # small-ish overrides
  discord =
    runCommand "discord"
      { buildInputs = [ final.makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper ${super.discord}/bin/Discord $out/bin/discord \
          --set "GDK_BACKEND" "x11"
      '';

  passff-host = super.passff-host.overrideAttrs ({ ... }: {
    patchPhase = ''
      sed -i 's@COMMAND = "pass"@COMMAND = "${final.pass-otp}/bin/pass"@' src/passff.py
    '';
  });

  ripgrep = super.ripgrep.override { withPCRE2 = true; };
  rofi = super.rofi.override { plugins = [ final.rofi-emoji ]; };
  mpd = final.mpdWithFeatures {
    features = [
      # Storage plugins
      "udisks"
      "webdav"
      # Input plugins
      "curl"
      "mms"
      "nfs"
      # "smbclient"
      # Archive support
      "bzip2"
      "zzip"
      # Decoder plugins
      "audiofile"
      "faad"
      "ffmpeg"
      "flac"
      "fluidsynth"
      "gme"
      "mad"
      "mikmod"
      "mpg123"
      "opus"
      "vorbis"
      # Encoder plugins
      "vorbisenc"
      "lame"
      # Filter plugins
      "libsamplerate"
      # Output plugins
      "alsa"
      "jack"
      "pulse"
      "shout"
      # Client support
      "libmpdclient"
      # Tag support
      "id3tag"
      # Misc
      "dbus"
      "expat"
      "icu"
      "pcre"
      "sqlite"
      "syslog"
      "systemd"
      "yajl"
      "zeroconf"
    ];
  };
}
