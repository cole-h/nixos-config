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

    bpool = {
      file = ../../../secrets/scadrial+scar/bpool;
    };

    "wgkiji.conf" = {
      file = ./kiji;
    };
  };
}
