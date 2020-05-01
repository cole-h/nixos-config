{ config, lib, pkgs, ... }:
let
  my-pinentry = with pkgs;
    writeShellScriptBin "my-pinentry" ''
      # choose pinentry depending on PINENTRY_USER_DATA
      # requires pinentry-curses and pinentry-gnome3
      # this *only works* with gpg 2
      # see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=802020

      if [ "''${PINENTRY_USER_DATA+x}" = "x" ]; then
        exec ${pinentry.gnome3}/bin/pinentry-gnome3 "$@"
      else
        exec ${pinentry.curses}/bin/pinentry-curses "$@"
      fi
    '';
  # my-pinentry = with pkgs;
  #   writeShellScriptBin "my-pinentry" ''
  #     # https://gist.github.com/msteen/6d1737a589e2ee5b492632182abdf658
  #     # http://unix.stackexchange.com/questions/236746/change-pinentry-program-temporarily-with-gpg-agent
  #     # https://github.com/keybase/keybase-issues/issues/1099#issuecomment-59313502

  #     if [[ -z "$PINENTRY_USER_DATA" ]]; then
  #       exec ${pinentry.gnome3}/bin/pinentry-gnome3 "$@"
  #     else
  #       exec ${pinentry.curses}/bin/pinentry-curses "$@"
  #       # exec ''${pinentry.curses}/bin/pinentry-curses --ttyname "$PINENTRY_USER_DATA" "$@"
  #     fi
  #   '';
in
{
  home.file = {
    ".mozilla/native-messaging-hosts".source = "${pkgs.passff-host}/lib/mozilla/native-messaging-hosts";

    ".gnupg/dirmngr.conf".text = ''
      # keyserver hkps://hkps.pool.sks-keyservers.net
      keyserver hkps://keys.openpgp.org
    '';
  };

  programs.gpg = {
    enable = true;

    settings = {
      default-key = "68B80D57B2E54AC3EC1F49B0B37E0F2371016A4C";

      use-agent = true;
      keyid-format = "0xlong";
      utf8-strings = true;

      no-emit-version = true;
      no-comments = true;
      ignore-time-conflict = true;
      allow-freeform-uid = true;
      personal-digest-preferences = "SHA256";
      cert-digest-algo = "SHA256";

      default-preference-list =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
      personal-cipher-preferences =
        "TWOFISH AES256 AES192 CAMELLIA256 CAMELLIA192 CAMELLIA128 AES CAST5";
    };
  };

  services.gpg-agent = {
    enable = true;

    # If this is enabled, `git push` does not work. Maybe other ssh actions as
    # well, but just that is enough to make me disable it. I still get prompted
    # for my GPG password, so no loss in functionality or protection.
    enableSshSupport = true;
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 86400;
    pinentryFlavor = null; # I use my own pinentry script :)
    verbose = true;

    sshKeys = [
      # GPG Auth subkey
      "83818B85C21D07A75D8BC0A09840E3B10F0BC4E7"

      # RSA key
      "ECD05CCB74C478364F6C42E7ADDF04E1BFC5F6A6"
    ];

    extraConfig = ''
      pinentry-program ${my-pinentry}/bin/my-pinentry
      allow-loopback-pinentry
      pinentry-timeout 600
      debug-all
    '';
  };
}
