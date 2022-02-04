{ config, lib, pkgs, ... }:
let
  cfg = config.services.mullvad-vpn;

  inherit (lib)
    mkOption
    types
    mkIf
    ;
in
{
  disabledModules = [ "services/networking/mullvad-vpn.nix" ];

  options.services.mullvad-vpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        This option enables Mullvad VPN daemon.
        This sets <option>networking.firewall.checkReversePath</option> to "loose", which might be undesirable for security.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.mullvad-vpn;
      defaultText = "pkgs.mullvad-vpn";
      description = ''
        The Mullvad package to use.
        The daemon must be accessable at $package/bin/mullvad-daemon.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    boot.kernelModules = [ "tun" ];

    # mullvad-daemon writes to /etc/iproute2/rt_tables
    networking.iproute2.enable = true;

    # See https://github.com/NixOS/nixpkgs/issues/113589
    networking.firewall.checkReversePath = "loose";

    systemd.services.mullvad-daemon = {
      description = "Mullvad VPN daemon";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];
      path = [
        pkgs.iproute2
        # Needed for ping
        "/run/wrappers"
      ];
      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mullvad-daemon -v --disable-stdout-timestamps";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}
