{ config, ... }:
let
  inherit (config.users.users)
    vin;
in
{
  age.secrets = {
    cargo = {
      owner = vin.name;
      file = ./cargo;
      path = "${vin.home}/.cargo/credentials";
    };

    sshcontrol = {
      owner = vin.name;
      file = ./sshcontrol;
      path = "${vin.home}/.gnupg/sshcontrol";
    };

    sshconfig = {
      owner = vin.name;
      file = ./sshconfig;
      path = "${vin.home}/.ssh/config";
    };

    cachix = {
      owner = vin.name;
      file = ./cachix;
      path = "${vin.home}/.config/cachix/cachix.dhall";
    };

    gitauth = {
      owner = vin.name;
      file = ./gitauth;
      path = "${vin.home}/.config/git/gitauth.inc";
    };

    imgur = {
      owner = vin.name;
      file = ./imgur;
      path = "${vin.home}/.config/imgur";
    };

    streamlink = {
      owner = vin.name;
      file = ./streamlink;
      path = "${vin.home}/.config/streamlink/config";
    };

    weechat-irc = {
      owner = vin.name;
      file = ./weechat-irc;
      path = "${vin.home}/.config/weechat/irc.conf";
    };

    weechat-sec = {
      owner = vin.name;
      file = ./weechat-sec;
      path = "${vin.home}/.config/weechat/sec.conf";
    };

    weechat-pem = {
      owner = vin.name;
      file = ./weechat-pem;
      path = "${vin.home}/.config/weechat/freenode.pem";
    };

    bpool = {
      file = ./bpool;
    };
  };
}
