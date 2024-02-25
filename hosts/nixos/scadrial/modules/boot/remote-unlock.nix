{ config, pkgs, lib, ... }:
let
  addr = lib.elemAt config.networking.interfaces.${interface}.ipv4.addresses 0;

  ip = addr.address;
  gateway = config.networking.defaultGateway.address;
  interface = config.networking.defaultGateway.interface;

  # https://github.com/NixOS/nixpkgs/pull/258250#issuecomment-1849556138
  # https://cyberchaos.dev/cyberchaoscreatures/nixlib/-/blob/ae8275e565018b6b256302dbc7203c941d654f6a/lib/ipUtil/default.nix
  mask = 
    let
      pow = base: exponent:
        if exponent == 0 then 1 else lib.fold (x: y: y * base) base (lib.range 2 exponent);

      encode = num:
        lib.concatStringsSep "." (map (x: toString (lib.mod (num / x) 256))
          (lib.reverseList (lib.genList (x: pow 2 (x * 8)) 4)));

      netmask = prefixLength:
        encode ((lib.foldl (x: y: 2 * x + 1) 0 (lib.range 1 prefixLength))
          * (pow 2 (32 - prefixLength)));
    in
  netmask addr.prefixLength;
in
{
  boot.kernelParams = [
    "ip=${ip}::${gateway}:${mask}:${config.networking.hostName}-initrd:${interface}:none"
  ];

  boot.initrd.kernelModules = [
    "igc" # Intel(R) 2.5G Ethernet Linux Driver
  ];

  boot.initrd.systemd.extraBin = {
    ssh-keygen = "${config.programs.ssh.package}/bin/ssh-keygen";
    true = "${pkgs.coreutils}/bin/true";
  };

  # Decrypt disk from SSH
  boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
  boot.initrd.systemd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.ignoreEmptyHostKeys = true;
  boot.initrd.network.ssh.port = 2222;
  boot.initrd.network.ssh.authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.extraConfig = ''
    HostKey /ssh_initrd_host_ed25519_key
  '';

  # Generate a host key on boot
  boot.initrd.systemd.services.sshd.preStart = ''
    [ ! -f /ssh_initrd_host_ed25519_key ] && /bin/ssh-keygen -t ed25519 -N "" -f /ssh_initrd_host_ed25519_key
    chmod 600 /ssh_initrd_host_ed25519_key
  '';

  # Rollback things to a blank snapshot (currently only /tmp)
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [ "initrd.target" ]; 
    after = [ "zfs-import.target" ];
    before = [  "sysroot.mount" ];
    path = [ config.boot.zfs.package ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback apool/ROOT/local/tmp@blank && echo "Rollback complete!" || echo "Rollback failed!"
    '';
  };

  # The NixOS module (currently) gives us 3 tries to unlock the disk, and a timeout counts as one
  # try, so this gives us 3 minutes / 3 tries before it shuts down.
  # If that happens, I can just WOL it again. (This is mostly to guard against me powering it on,
  # then forgetting about it when I don't have physical access.)
  boot.zfs.passwordTimeout = 60;

  boot.initrd.systemd.services.poweroff-on-unlock-fail = {
    description = "Poweroff if unlocking the root disk failed";
    unitConfig.DefaultDependencies = "no";
    serviceConfig.type = "oneshot";
    serviceConfig.ExecStart = "systemctl poweroff";
  };

  boot.initrd.systemd.targets.zfs-import = {
    unitConfig.OnFailure = "poweroff-on-unlock-fail.service";
  };

  # Don't wait for udev to finish processing events.
  boot.initrd.systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [ "" "/bin/true" ];
}
