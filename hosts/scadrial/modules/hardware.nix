{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    configFile = pkgs.runCommand "default.pa" { } ''
      sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
        ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    '';
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.amd.updateMicrocode = true;

  # Use schedutil governor.
  powerManagement.cpuFreqGovernor = "schedutil";

  # Don't block on importing tank zpool.
  # Thanks, Infinisil: https://github.com/Infinisil/system/commit/054d68f0660a608999fccf2f63e3f33dc7c6e0e9
  systemd.services.zfs-import-tank.before = lib.mkForce [ "media.mount" ];
  systemd.targets.zfs-import.after = lib.mkForce [ ];
  fileSystems."/media".options = [ "nofail" ];

  # Don't wait for udev to finish processing events.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
}
