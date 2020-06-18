{ pkgs, lib, ... }:
let
  linux_zen_pkg = { fetchurl, buildLinux, ... }@args:
    buildLinux (args // (
      let version = "5.7.2-zen1"; in
      {
        inherit version;
        modDirVersion = version;

        # https://github.com/zen-kernel/zen-kernel/releases
        src = fetchurl {
          url = "https://github.com/zen-kernel/zen-kernel/archive/v${version}.tar.gz";
          sha256 = "132rvfb6g82v3v017w2h4dgglrqn99cghyz5h5plzy4mzglazg2v";
        };

        kernelPatches = with pkgs; [
          kernelPatches.bridge_stp_helper
          kernelPatches.request_key_helper
          kernelPatches.export_kernel_fpu_functions."5.3"
        ];

        structuredExtraConfig = with lib.kernel; {
          PREEMPT_VOLUNTARY = lib.mkForce {
            optional = true;
            tristate = null;
          };

          PREEMPT = yes;
          PREEMPT_COUNT = yes;
          PREEMPTION = yes;
        };

        # HARDIRQS_SW_RESEND y
        #
        # IRQ_TIME_ACCOUNTING y
        # HAVE_SCHED_AVG_IRQ y
        #
        # PREEMPT_RCU y
        # RCU_EXPERT y
        # TASKS_RCU y
        # RCU_FANOUT 64
        # RCU_FANOUT_LEAF 16
        # RCU_FAST_NO_HZ y
        # RCU_BOOST y
        # RCU_BOOST_DELAY 500
        #
        # UCLAMP_TASK y
        # UCLAMP_BUCKETS_COUNT 5
        #
        # NUMA_BALANCING y
        # NUMA_BALANCING_DEFAULT_ENABLED y
        #
        # UCLAMP_TASK_GROUP y
        #
        # CHECKPOINT_RESTORE y

        extraMeta.branch = lib.versions.majorMinor version;
      }
    ) // (args.argsOverride or { }));

  linux_zen = pkgs.callPackage linux_zen_pkg { };
  linuxPackages_zen = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_zen);
in
{
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    supportedFilesystems = [ "zfs" "ntfs" ];
    initrd.kernelModules = [ "nouveau" ];
    tmpOnTmpfs = true;
    # plymouth.enable = true; # requires https://github.com/NixOS/nixpkgs/pull/88789

    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = linuxPackages_zen;
    extraModulePackages = [ linuxPackages_zen.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
      # options snd-hda-intel vid=8086 pid=8ca0 snoop=0
      # options snd_hda_intel vid=8086 pid=8ca0 snoop=0
    '';

    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "kernel.printk" = "3 4 3 3"; # don't let logging bleed into TTY
    };

    kernelParams = [
      "udev.log_priority=3"
    ];

    # Allow emulated cross compilation for aarch64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
