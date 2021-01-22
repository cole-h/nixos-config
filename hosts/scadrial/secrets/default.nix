{ config, ... }:
let
  vin = config.users.users.vin;
in
{
  sops.secrets = {
    cargo = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./cargo;
      path = "${vin.home}/.cargo/credentials";
    };

    sshcontrol = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./sshcontrol;
      path = "${vin.home}/.gnupg/sshcontrol";
    };

    sshconfig = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./sshconfig;
      path = "${vin.home}/.ssh/config";
    };

    cachix = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./cachix;
      path = "${vin.home}/.config/cachix/cachix.dhall";
    };

    gitauth = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./gitauth;
      path = "${vin.home}/.config/git/gitauth.inc";
    };

    imgur = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./imgur;
      path = "${vin.home}/.config/imgur";
    };

    streamlink = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./streamlink;
      path = "${vin.home}/.config/streamlink/config";
    };

    weechat-irc = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./weechat-irc;
      path = "${vin.home}/flake/users/${vin.name}/modules/weechat/config/irc.conf";
    };

    weechat-sec = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./weechat-sec;
      path = "${vin.home}/flake/users/${vin.name}/modules/weechat/config/sec.conf";
    };

    weechat-pem = {
      owner = vin.name;
      format = "binary";
      sopsFile = ./weechat-pem;
      path = "${vin.home}/flake/users/${vin.name}/modules/weechat/config/freenode.pem";
    };
  };
}
