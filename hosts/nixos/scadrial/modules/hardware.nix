{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  # Use pipewire for sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.intel.updateMicrocode = true;

  # Enable RAS event logging.
  hardware.rasdaemon.enable = true;
  hardware.rasdaemon.record = true;
  hardware.rasdaemon.extraModules = [
    "i7core_edac"
  ];

  # Use schedutil governor.
  powerManagement.cpuFreqGovernor = "schedutil";

  # Don't wait for udev to finish processing events.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];

  # Better swap behavior?
  zramSwap.enable = true;
}
