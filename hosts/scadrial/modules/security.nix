{ ... }:

{
  # Enable `doas`, a `sudo` replacement.
  security.doas = {
    enable = true;
    extraRules = [
      { groups = [ "wheel" ]; keepEnv = true; persist = true; }
      { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "virsh"; }
    ];
  };

  # To allow home-manager's provided swaylock actually unlock.
  security.pam.services.swaylock = { };
}
