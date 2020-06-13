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
  # n, 1, +1M, +512M, ef00  (EFI boot)
  # n, 2, ...,  +16G, 8200  (swap)
  # n, 3, ...,   ...,  ...  (Linux)
  # c, 3, "tank" -- set part label
  # w

mkfs.fat -F 32 -n boot $DISK-part1
mkswap -L swap $DISK-part2
swapon $DISK-part2 # otherwise, nixos-install won't generate hardware config for this

zpool create \
    -O atime=off \
    -O compression=on \
    -O encryption=aes-256-gcm -O keyformat=passphrase \
    -O xattr=sa \
    -O acltype=posixacl \
    -O mountpoint=none \
    -R /mnt \
    tank $DISK-part3

# https://gist.github.com/LnL7/5701d70f46ea23276840a6b1c404597f
# maybe don't need mountpoint=legacy except for /nix?
zfs create -o canmount=off tank/system
zfs create -o mountpoint=legacy tank/system/root
zfs create -o mountpoint=legacy tank/system/var # maybe don't need legacy
zfs create -o mountpoint=legacy tank/system/media # maybe don't need legacy
zfs create -o canmount=off tank/local
zfs create -o mountpoint=legacy tank/local/nix
zfs create -o canmount=off tank/user
zfs create -o mountpoint=legacy tank/user/home # maybe don't need legacy

# create snapshot of everything `@blank` -- easy to switch to tmpfs if I want
zfs snapshot tank/system@blank
# roll back with `zfs rollback -r rpool/local/root@blank`

mount -t zfs tank/system/root /mnt
mkdir -p /mnt/boot /mnt/var /mnt/media /mnt/nix /mnt/home
mount -t zfs tank/system/var /mnt/var
mount -t zfs tank/system/media /mnt/media
mount -t zfs tank/local/nix /mnt/nix
mount -t zfs tank/user/home /mnt/home
mount $DISK-part1 /mnt/boot
```


## 2. install

``` sh
git clone https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config

nixos-generate-config --root /mnt --dir /tmp/nixos-config/hosts/scadrial

export NIXOS_CONFIG=/mnt/tmp/nixos-config/hosts/scadrial/configuration.nix

nixos-install

nixos-enter
ln -s /{home/vin/.config/nixpkgs/hosts/scadrial,etc/nixos}/configuration.nix
ln -s /{home/vin/.config/nixpkgs/hosts/scadrial,etc/nixos}/hardware-configuration.nix
doas -u vin bash && \
  rsync -a /tmp/nixos-config/ ~/.config/nixpkgs && \
  chown -R vin ~/.config # maybe unnecessary

systemctl reboot

# set up gpg and get secrets
gpg --import # ...
gpg -K --with-keygrip | tail -2 | sed 's/.*Keygrip = //' >> ~/.gnupg/sshcontrol # add auth subkey to sshcontrol
git clone git@github.com:cole-h/nix-secrets /mnt/tmp/dotfiles/secrets
nix-shell -p git-crypt --run 'git crypt unlock'
rm ~/.gnupg/sshcontrol
git -C ~/.config/nixpkgs submodule update --init

git clone https://github.com/rycee/home-manager ~/workspace/vcs/home-manager
git clone https://github.com/alacritty/alacritty ~/workspace/vcs/alacritty
git clone https://github.com/cole-h/passrs ~/workspace/langs/rust/passrs
nix-shell ~/workspace/vcs/home-manager -A install
doom sync
# copy FF profile
# copy sonarr settings (watched shows, etc)
# copy ssh config and hosts (probably should just manage this with h-m or smth)
```
