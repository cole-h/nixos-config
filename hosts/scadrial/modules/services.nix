{ config, pkgs, lib, ... }:
{
  # It fails nowadays due to "Read event structure of invalid size.",
  # dunno why, but I don't need it.
  systemd.services."systemd-rfkill".enable = false;
  systemd.sockets."systemd-rfkill".enable = false;

  # https://tailscale.com/kb/1063/install-nixos
  services.tailscale.enable = true;

  # Enable Gnome's SSH agent
  services.gnome.gnome-keyring.enable = true;

  # Scrub the disk regularly to ensure integrity
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Automount USB
  services.gvfs.enable = true;
  services.gvfs.package = pkgs.gvfs.override { gnomeSupport = false; };

  # Hide the "help" message
  services.getty.helpLine = lib.mkForce "";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Necessary for discovering network printers.
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # services.udev.packages for packages with udev rules
  # SUBSYSTEMS=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eed2", TAG+="uaccess", RUN{builtin}+="uaccess"
  services.udev.extraRules =
    # Set noop scheduler for zfs partitions
    ''
      KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';

  services.greetd = {
    enable = true;
    settings =
      let
        greeting = lib.escapeShellArg ''"There's always another secret."'';
        command = lib.concatStringsSep " " [
          "${pkgs.greetd.tuigreet}/bin/tuigreet"
          "--time"
          "--greeting"
          "${greeting}"
          "--cmd"
          ''"systemd-cat -t sway -- sway"''
        ];
      in
      {
        default_session = {
          inherit command;
          user = "greeter";
        };
      };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
  };

  services.mullvad.enable = true;

  services.nscd.enableNsncd = true;

  services.safeeyes.enable = true;

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_15;
  services.postgresql.authentication = ''
    local all all trust
    host all all 127.0.0.1/32 trust
    host all all ::1/128 trust
  '';
}
