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

  # Use schedutil governor.
  powerManagement.cpuFreqGovernor = "schedutil";

  # Don't wait for udev to finish processing events.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  boot.kernelParams = [ "module_blacklist=i915" ];
}
