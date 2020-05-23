{ pkgs, ... }:
let
  caps2esc = pkgs.callPackage ../../../drvs/caps2esc { };
in
{
  # For ZFS on SSD.
  # services.zfs.trim.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  services.interception-tools = {
    enable = true;
    plugins = [ caps2esc ];
    udevmonConfig = ''
      - JOB: "intercept -g $DEVNODE | ${caps2esc}/bin/caps2esc -n | uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };
}
