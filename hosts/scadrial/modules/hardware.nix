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
  hardware.nvidia.powerManagement.enable = false;
  boot.kernelParams = [ "module_blacklist=i915" ];

  system.replaceRuntimeDependencies = [
    {
      original = pkgs.alsa-ucm-conf;
      replacement = pkgs.alsa-ucm-conf.overrideAttrs ({ patches ? [ ], ... }: {
        patches = patches ++ [
          # https://github.com/alsa-project/alsa-ucm-conf/pull/267
          (pkgs.writeText "support-my-mobo.patch" ''
            diff --git a/ucm2/USB-Audio/USB-Audio.conf b/ucm2/USB-Audio/USB-Audio.conf
            index 325d48c..a028eb1 100644
            --- a/ucm2/USB-Audio/USB-Audio.conf
            +++ b/ucm2/USB-Audio/USB-Audio.conf
            @@ -41,7 +41,8 @@ If.realtek-alc4080 {
             		# 0db0:1feb MSI Edge Wifi Z690
             		# 0db0:419c MSI MPG X570S Carbon Max Wifi
             		# 0db0:a073 MSI MAG X570S Torpedo Max
            -		Regex "USB((0b05:(1996|1a2[07]))|(0db0:(1feb|419c|a073)))"
            +		# 0db0:6c09 MSI MPG Z790 Cargon Wifi
            +		Regex "USB((0b05:(1996|1a2[07]))|(0db0:(1feb|419c|a073|6c09)))"
             	}
             	True.Define.ProfileName "Realtek/ALC4080"
             }
          '')
        ];
      });
    }
  ];
}
