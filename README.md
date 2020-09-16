# dotfiles

### Hostnames

I'm a big fan of [Brandon Sanderson], so that's where all of my hostnames come
from (see [`names`](./names)). They were manually copy-pasted from throughout the
[Coppermind] wiki and are [planets, shards], general terms, worldhoppers, and
[locations] throughout his works. Any of these that had a space or apostrophe
were discarded.

[Brandon Sanderson]: https://www.brandonsanderson.com/
[hostnames]: ./hostnames
[Coppermind]: https://coppermind.net/wiki/Coppermind:Welcome
[planets, shards]: https://coppermind.net/wiki/Cosmere#Planets
[locations]: https://coppermind.net/wiki/Category:Locations

---

# Setup stuff

https://grahamc.com/blog/nixos-on-zfs

https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

## 0. preparations
  - make iso with `nix build -f ~/workspace/vcs/nixpkgs/nixos-unstable/nixos config.system.build.isoImage -I nixos-config=iso.nix`
  - backup stateful stuff
    - FF profile
    - sonarr settings (watched shows, etc)
    - fish shell history

## 1. partition
  - 512MiB /boot at the beginning
  - 16GiB swap partition at the beginning
  - rest "linux partition" (for ZFS) -- don't forget native encryption
    ("encryption=on") and "compression=on"
    - tank/system (none) -- should be backed up
    - tank/system/root (legacy)
    - tank/system/var (legacy)
    - tank/local (none) -- shouldn't be backed up
    - tank/local/nix (legacy)
    - tank/user (none) -- should be backed up
    - tank/user/home (legacy)

``` sh
export DISK=/dev/disk/by-id/.....
gdisk $DISK
  # o (delete all partitions + protective mbr)
  # n, 1, +1M,   +1G, ef00  (EFI boot)
  # n, 2, ...,  +16G, 8200  (swap)
  # n, 3, ...,  ....,  ...  (Linux)
  # c, 3, "[a-z]pool" -- set part label
  # w

mkfs.fat -F 32 -n boot $DISK-part1
mkswap -L swap $DISK-part2
swapon $DISK-part2 # otherwise, nixos-install won't generate hardware config for this

zpool create \
    -O atime=off \
    -O compression=zstd \
    # apparently gcm is faster than ccm
    -O encryption=aes-256-gcm -O keyformat=passphrase \
    -O xattr=sa \
    -O acltype=posixacl \
    -O mountpoint=none \
    # my SSD (ADATA SU800) may or may not lie that it uses a 512B physical block
    # size; ashift of 13 (8k) shouldn't really hurt, according to various people
    -O ashift=13 \
    -R /mnt \
    rpool $DISK-part3

# https://gist.github.com/LnL7/5701d70f46ea23276840a6b1c404597f
# maybe don't need mountpoint=legacy except for /nix?
zfs create -o canmount=off rpool/system
zfs create -o mountpoint=legacy rpool/system/root
zfs create -o mountpoint=legacy rpool/system/var # maybe don't need legacy
zfs create -o mountpoint=legacy rpool/system/media # maybe don't need legacy
zfs create -o canmount=off rpool/local
zfs create -o mountpoint=legacy rpool/local/nix
zfs create -o canmount=off rpool/user
zfs create -o mountpoint=legacy rpool/user/home # maybe don't need legacy
zfs create -V 302G rpool/win10

# create snapshot of everything `@blank` -- easy to switch to tmpfs if I want
zfs snapshot rpool/system@blank
# roll back with `zfs rollback -r rpool/local/root@blank`

mount -t zfs rpool/system/root /mnt
mkdir -p /mnt/boot /mnt/var /mnt/media /mnt/nix /mnt/home
mount -t zfs rpool/system/var /mnt/var
mount -t zfs rpool/system/media /mnt/media
mount -t zfs rpool/local/nix /mnt/nix
mount -t zfs rpool/user/home /mnt/home
mount $DISK-part1 /mnt/boot
```


## 2. install

``` sh
gpg --import # import secret key for live ISO to be able to clone secrets
gpg -K --with-keygrip | tail -2 | sed 's/.*Keygrip = //' >> ~/.gnupg/sshcontrol # add auth subkey to sshcontrol
git clone --recurse-submodules https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config
git -C /mnt/tmp/nixos-config/secrets crypt unlock

nixos-generate-config --root /mnt --dir /tmp/nixos-config/hosts/scadrial

nixos-install --flake /mnt/tmp/nixos-config#scadrial

nixos-enter
  doas -u vin bash
    gpg --import # import secret key again, for user
    mv /tmp/nixos-config ~/flake
    chown vin:users ~/flake

systemctl reboot

git clone https://github.com/cole-h/passrs ~/workspace/langs/rust/passrs
mkdir -p ~/workspace/vcs && cd ~/workspace/vcs
git clone https://github.com/nixos/ofborg
git clone https://github.com/nix-community/home-manager
git clone https://github.com/alacritty/alacritty
git clone https://github.com/nixos/nixpkgs nixpkgs/master # and the other branches
git clone https://github.com/nixos/nix
git clone https://github.com/fish-shell/fish-shell
git clone https://github.com/ofborg/infrastructure

git clone --reference nixpkgs/master https://spectrum-os.org/git/nixpkgs spectrum/nixpkgs # and the other stuff
# chroumiumos/platform/crosvm

# copy FF profile from backup
# copy sonarr settings (watched shows, etc) from backup
# copy fish shell history from backup
  ```
