{ lib, pkgs, ... }:
{
  # FIXME: once linux 6.7 is released and in nixpkgs, AND ZFS supports 6.7 kernels
  # https://github.com/NixOS/nixpkgs/pull/271703
  # https://github.com/openzfs/zfs/issues/15582
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages =
    let
      kernelPackage = pkgs.linuxKernel.packages.linux_6_1.kernel;
    in
    lib.mkForce
      (pkgs.linuxPackagesFor
        (kernelPackage.override {
          kernelPatches =
            lib.subtractLists
              [
                # This Dell XPS patch doesn't apply to 6.1.23
                # Caused by: https://github.com/NixOS/nixpkgs/pull/255824
                pkgs.linuxKernel.kernelPatches.dell_xps_regression
              ]
              kernelPackage.kernelPatches;

          # X86_PLATFORM_DRIVERS_HP option is unused on 6.1.23
          # Caused by: https://github.com/NixOS/nixpkgs/pull/255846
          structuredExtraConfig = {
            X86_PLATFORM_DRIVERS_HP = lib.mkForce lib.kernel.unset;
          };

          argsOverride = rec {
            version = "6.1.23";
            modDirVersion = version;
            src = pkgs.fetchurl {
              url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
              sha256 = "sha256-dFg3LodQr+N/0aw+erPCLyxgGPdg+BNAVaA/VKuj6+s=";
            };
          };
        }));

  boot.kernelParams = [
    "module_blacklist=i915"
  ];

  boot.kernelPatches = [
    {
      name = "nouveau.patch";
      patch = ./nouveau.patch;
    }
  ];

  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      pname = "nvidia-gsp-firmware";
      version = "525.60.11";
      # FIXME: will be 535.113.01 in linux 6.7 -- grep the linux source for `ad102_gsps` to find the version in case it changes
      # https://elixir.bootlin.com/linux/latest/A/ident/ad102_gsps ("as a variable")
      # Currently defined in: drivers/gpu/drm/nouveau/nvkm/subdev/gsp/ad102.c
      src = pkgs.fetchurl {
        url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/525.60.11/NVIDIA-Linux-x86_64-525.60.11.run";
        sha256 = "sha256-gW7mwuCBPMw9SnlY9x/EmjfGDv4dUdYUbBznJAOYPV0=";
      };

      dontBuild = true;
      dontFixup = true;
      dontStrip = true;

      unpackPhase = ''
        sh $src --extract-only --target build
        cd build
      '';

      installPhase = ''
        mkdir -p $out/lib/firmware/nvidia/ad102/gsp
        mv firmware/gsp_ad10x.bin $out/lib/firmware/nvidia/ad102/gsp/gsp-5256011.bin
      '';
    })
  ];
}
