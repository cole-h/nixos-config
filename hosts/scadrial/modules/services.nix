{ pkgs, lib, ... }:
let
  caps2esc = pkgs.callPackage ../../../drvs/caps2esc { };
in
{
  services.znapzend = {
    enable = true;
    pure = true;
    zetup = {
      "rpool/system" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "15min=>5min,4h=>15min,4d=>1h,1w=>1d,1m=>1w";
        recursive = true;
      };
      "rpool/user" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "15min=>5min,4h=>15min,4d=>1h,1w=>1d,1m=>1w";
        recursive = true;
      };
      "rpool/win10" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "15min=>5min,4h=>15min,4d=>1h,1w=>1d,1m=>1w";
      };
    };
  };

  # Scrub the disk regularly to ensure integrity
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Automount USB
  services.gvfs.enable = true;

  # Hide the "help" message
  services.mingetty.helpLine = lib.mkForce "";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

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

  # No longer necessary, now that I have a CTRL. However, keep it around since I
  # might want it for other devices.
  # services.interception-tools = {
  #   enable = false;
  #   plugins = [ caps2esc ];
  #   udevmonConfig = ''
  #     - JOB: "intercept -g $DEVNODE | caps2esc -n | uinput -d $DEVNODE"
  #       DEVICE:
  #         EVENTS:
  #           EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
  #   '';
  # };

  # services.udev.packages for packages with udev rules
  # services.udev.extraRules = ''
  #   SUBSYSTEMS=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eed2", TAG+="uaccess", RUN{builtin}+="uaccess"
  # '';
}
