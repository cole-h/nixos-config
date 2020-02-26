{ config, lib, pkgs, ... }:

let
  my-pinentry = with pkgs;
    writeShellScriptBin "my-pinentry" ''
      # choose pinentry depending on PINENTRY_USER_DATA
      # requires pinentry-curses and pinentry-gnome3
      # this *only works* with gpg 2
      # see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=802020

      set -Ceu

      case "''${PINENTRY_USER_DATA-}" in
      *gtk*)
        exec ${pinentry.gnome3}/bin/pinentry-gnome3 "$@"
        ;;
      esac

      exec ${pinentry.curses}/bin/pinentry-curses "$@"
    '';
in {
  home = {
    packages = [ my-pinentry ];

    file = {
      ".gnupg/dirmngr.conf".text = "keyserver hkps://keys.openpgp.org";
      # ".gnupg/gpg-agent.conf".text = ''
      #   pinentry-program ${my-pinentry}/bin/my-pinentry
      #   allow-loopback-pinentry
      #   pinentry-timeout 600
      #   default-cache-ttl 600
      #   default-cache-ttl-ssh 86400
      #   max-cache-ttl 7200
      #   max-cache-ttl-ssh 86400
      #   # enable-ssh-support
      #   verbose
      # '';
    };
  };

  programs.gpg = {
    enable = true;

    settings = {
      default-key = "68B80D57B2E54AC3EC1F49B0B37E0F2371016A4C";

      use-agent = true;
      keyid-format = "0xlong";
      utf8-strings = true;

      personal-digest-preferences = "SHA256";
      cert-digest-algo = "SHA256";
      default-preference-list =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
      personal-cipher-preferences =
        "TWOFISH AES256 AES192 CAMELLIA256 CAMELLIA192 CAMELLIA128 AES CAST5";
      no-emit-version = true;
      no-comments = true;
      ignore-time-conflict = true;
      allow-freeform-uid = true;
    };
  };

  services.gpg-agent = {
    enable = true;

    # enableSshSupport = true; # TODO: why did I have this disabled in my original config
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 86400;
    pinentryFlavor = null; # I use my own pinentry script :)
    sshKeys = [
      "83818B85C21D07A75D8BC0A09840E3B10F0BC4E7"
      "ECD05CCB74C478364F6C42E7ADDF04E1BFC5F6A6"
    ];
    verbose = true;
    extraConfig = ''
      pinentry-program ${my-pinentry}/bin/my-pinentry
      allow-loopback-pinentry
      pinentry-timeout 600
    '';
  };
}
