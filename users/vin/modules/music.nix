{ super, config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    tidal-hifi
    youtube-music
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
            while ! echo | ${pkgs.pulseaudio}/bin/pacat -v; do sleep 1; done
            ${pkgs.coreutils}/bin/sleep infinity | ${pkgs.pulseaudio}/bin/pacat -v
          '';
        in
        toString script;
    };
    Unit = {
      After = [ "pipewire-pulse.service" "sway-session.target" ];
      Requires = [ "pipewire-pulse.service" ];
    };
  };
}
