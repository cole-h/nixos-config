{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # I use cadence to start jack, which wants to manage its own pulseaudio.
  systemd.user = {
    services.pulseaudio.enable = lib.mkForce false;
    sockets.pulseaudio.enable = lib.mkForce false;
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.intel.updateMicrocode = true;
}
