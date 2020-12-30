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

## 0. preparation
  - make iso with `nix build .#iso`
  - backup stateful stuff if reinstalling to same disk
    - FF profile
    - sonarr settings (watched shows, etc)
    - fish shell history

## 1. partition
  - 2GiB /boot at the beginning
  - 32GiB swap partition at the beginning
  - rest "linux partition" (for ZFS) -- don't forget native encryption
    ("encryption=aes-256-gcm") and "compression=zstd"
    - apool/ROOT/system (none) -- should be backed up
    - apool/ROOT/system/root (legacy)
    - apool/ROOT/system/var (legacy)
    - apool/ROOT/local (none) -- shouldn't be backed up
    - apool/ROOT/local/nix (legacy)
    - apool/ROOT/user (none) -- should be backed up
    - apool/ROOT/user/home (legacy)
    - apool/ROOT/user/home/vin (legacy)
    - apool/ROOT/user/home/vin/Downloads (legacy) -- don't backup
    - apool/reserved (none)

``` sh
# This section should be run as root.

export DISK=/dev/disk/by-id/.....
gdisk $DISK
  # o (delete all partitions + protective mbr)
  # n, 1, +1M,   +2G, ef00  (EFI boot)
  # n, 2, ...,  +32G, 8200  (swap)
  # n, 3, ...,  ....,  ...  (Linux)
  # c, 3, "[a-z]pool" -- set part label
  # w

mkfs.fat -F 32 -n boot $DISK-part1
mkswap -L swap $DISK-part2

zpool create \
    -O mountpoint=none \
    # SSDs may or may not lie that it uses a 512B physical block size;
    # ashift of 12 (4k) shouldn't really hurt, according to various
    # people
    -o ashift=12 \
    -R /mnt \
    apool $DISK-part3

zfs create \
    -o atime=off \
    # requires ZoL 2.0
    -o compression=zstd \
    # apparently gcm is faster than ccm
    -o encryption=aes-256-gcm -o keyformat=passphrase \
    -o xattr=sa \
    -o acltype=posixacl \
    apool/ROOT

# https://gist.github.com/LnL7/5701d70f46ea23276840a6b1c404597f
# maybe don't need mountpoint=legacy except for /nix?
alias nomount='zfs create -o canmount=off'
alias legacy='zfs create -o mountpoint=legacy'
nomount apool/ROOT/system
legacy apool/ROOT/system/root
legacy apool/ROOT/system/var
legacy apool/ROOT/system/media
nomount apool/ROOT/local
legacy apool/ROOT/local/nix
nomount apool/ROOT/user
nomount apool/ROOT/user/vin
legacy apool/ROOT/user/vin/home
legacy apool/ROOT/user/vin/home/Downloads
# zfs create -V 302G apool/ROOT/win10

# keep space available in case it's ever needed
# to free up the space, `zfs set refreservation=none apool/reserved`
nomount -o refreservation=1G apool/reserved

# create snapshot of everything `@blank` -- easy to switch to tmpfs if I want
zfs snapshot -r apool/ROOT@blank
# roll back with `zfs rollback -r apool/ROOT@blank`

mkdir -p /tmp/sys
zpool import rpool tank
mount -t zfs rpool/system/root /tmp/sys
zfs load-key -L file:///tmp/sys/tank-key tank

mount -t zfs apool/ROOT/system/root /mnt
cp /tmp/sys/tank-key /mnt
mkdir -p /mnt/{boot,var,media,nix,home/vin,mnt}
mount -t zfs apool/ROOT/system/var /mnt/var
mount -t zfs apool/ROOT/local/nix /mnt/nix
mount -t zfs apool/ROOT/user/vin/home /mnt/home/vin
mount -t zfs tank/system/media /mnt/media
mount $DISK-part1 /mnt/boot
```


## 2. install

``` sh
# This section should be run as the ISO user

gpg --import # import secret key for live ISO to be able to clone secrets
gpg -K --with-keygrip | tail -2 | sed 's/.*Keygrip = //' >> ~/.gnupg/sshcontrol # add auth subkey to sshcontrol
git clone --recurse-submodules https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config
git -C /mnt/tmp/nixos-config/secrets crypt unlock

doas swapon $DISK-part2 # otherwise, nixos-install won't generate hardware config for this
nixos-generate-config --root /mnt --dir /tmp/nixos-config/hosts/scadrial

sed "s@networking.hostId = \".*\"@networking.hostId = \"$(head -c 8 /etc/machine-id)\"@" -i hosts/scadrial/modules/networking.nix
nix build /mnt/tmp/nixos-config#bootstrap --out-link /tmp/outsystem
nixos-install --system /tmp/outsystem --no-root-passwd --no-channel-copy

nixos-enter
  echo "nameserver 192.168.1.212" >> /etc/resolv.conf
  nix-daemon &
  doas -u vin bash
    gpg --import # import secret key again, for user
    doas mv /tmp/nixos-config ~/flake
    doas chown -R vin:users ~/flake
    # might need to get pinentry-curses and set pinentry-program in
    # ~/.gnupg/gpg-agent.conf
    doas nixos-rebuild switch --flake .

systemctl reboot
```


## 3. setup

``` sh
# This section should be run as the default user (vin, in this case)

doas mount -t zfs rpool/user/home /mnt
rsync -aP /mnt/vin/.password-store/ ~/.password-store/
rsync -aP /mnt/vin/.mozilla/ ~/.mozilla/
rsync -aP /mnt/vin/workspace/ ~/workspace/
ln -s ~/.local/share/hydrus/db ~/workspace/vcs/hydrus/db
rsync -a /mnt/vin/.cache/.j4_history ~/.cache/
rsync -aP --ignore-existing /mnt/vin/.local/share/chatterino/ ~/.local/share/chatterino/
rsync -a /mnt/vin/.local/share/zoxide/ ~/.local/share/zoxide/
rsync -a /mnt/vin/.local/share/fish/fish_history ~/.local/share/fish/
# verify PCI addresses in windows10.xml and start.sh / revert.sh, then:
doas virsh define ..../windows10.xml

# update snapshot settings to use new dataset(s)
# copy sonarr settings (watched shows, etc) from backup
# fish_config for dracula colors
# syncthing setup
# copy weechat logs
# emacs all-the-icons-install-fonts to ~/.local/share/fonts
```
