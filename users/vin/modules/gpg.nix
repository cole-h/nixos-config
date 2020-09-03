{ config, lib, pkgs, my, ... }:

{
  home.file = {
    ".mozilla/native-messaging-hosts".source = "${pkgs.passff-host}/lib/mozilla/native-messaging-hosts";

    ".gnupg/dirmngr.conf".text = ''
      # keyserver hkps://hkps.pool.sks-keyservers.net
      keyserver hkps://keys.openpgp.org
    '';

    ".gnupg/sshcontrol".source = config.lib.file.mkOutOfStoreSymlink my.secrets.sshcontrol;

    ".gnupg/gpg-agent.conf".text = ''
      default-cache-ttl 86400
      max-cache-ttl 43200
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

      personal-cipher-preferences =
        "TWOFISH AES256 AES192 CAMELLIA256 CAMELLIA192 CAMELLIA128 AES CAST5";
    };
  };
}
