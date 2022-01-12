{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  # Use pulseaudio for sound.
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.amd.updateMicrocode = true;

  # Use schedutil governor.
  powerManagement.cpuFreqGovernor = "schedutil";

  # Don't wait for udev to finish processing events.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];

  # May be necessary for the 6700XT?
  # hardware.enableRedistributableFirmware = true;
}
