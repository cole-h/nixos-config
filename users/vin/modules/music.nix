{ super, config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    tidal-hifi
  ];

  # XXX: super duper ultra hack to make my FiiO K3 DAC not suspend when
  # it's not playing audio...
  systemd.user.services."fiio-k3-hack" = {
    Install = {
      WantedBy = [ "pipewire-pulse.service" ];
    };
    Service = {
      ExecStart =
        let
          script = pkgs.writeShellScript "fiio-k3-hack" ''
            ${pkgs.coreutils}/bin/sleep infinity | ${pkgs.pulseaudio}/bin/pacat -v
          '';
        in
        toString script;
    };
    Unit = {
      After = [ "pipewire-pulse.service" ];
      Requires = [ "pipewire-pulse.service" ];
    };
  };
}
