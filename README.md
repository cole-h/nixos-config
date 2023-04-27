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
    - apool/r (none)
    - apool/r/local (none) -- shouldn't be backed up
    - apool/r/local/root (legacy)
    - apool/r/local/nix (legacy)
    - apool/r/local/tmp (legacy)
    - apool/r/local/var (legacy)
    - apool/r/safe (none) -- "safe" to back up
    - apool/r/safe/state/home (legacy)
    - apool/r/safe/state/home/vin (legacy)
    - apool/r/safe/state/home/vin/Downloads (legacy) -- don't backup
    - apool/alloc (none) -- 1G file to make sure we don't run out of space (can be freed to make fs stuff work again)

``` sh
# This section should be run as root.

export DISK=/dev/disk/by-id/.....
gdisk $DISK
  # o (delete all partitions + protective mbr)
  # n, 1, +1M,   +2G, ef00  (EFI boot)
  # n, 2, ...,  +32G, 8200  (swap)
  # n, 3, ...,  ....,  ...  (Linux)
  # c, 3, "[a-z][0-9]?pool" -- set part label
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
    -o canmount=off \
    -o atime=off \
    # requires ZoL 2.0
    -o compression=zstd \
    # apparently gcm is faster than ccm
    -o encryption=aes-256-gcm -o keyformat=passphrase \
    -o xattr=sa \
    -o acltype=posixacl \
    apool/r

# https://gist.github.com/LnL7/5701d70f46ea23276840a6b1c404597f
# maybe don't need mountpoint=legacy except for /nix?
alias nomount='zfs create -o canmount=off'
alias legacy='zfs create -o mountpoint=legacy'
nomount apool/r
nomount apool/r/local
legacy apool/r/local/root # /
legacy apool/r/local/tmp # /tmp
legacy apool/r/local/nix # /nix
legacy apool/r/local/var # /var
nomount apool/r/safe
legacy apool/r/safe/state
legacy -p apool/r/safe/state/home/vin/Downloads # create /home, /home/vin, and /home/vin/Downloads datasets
# zfs create -s -V 400G apool/r/win10

# keep space available in case it's ever needed
# to free up the space, `zfs set refreservation=none apool/alloc`
nomount -o refreservation=1G apool/alloc

# create snapshot of everything `@blank` -- easy to switch to tmpfs if I want
zfs snapshot -r apool/r@blank
# roll back with `zfs rollback -r apool/r@blank`

alias zmnt='mount -t zfs'
zmnt apool/r/local/root /mnt
mkdir -p /mnt/{boot,var,nix,state/home/vin/Downloads,mnt,shares/media}
zmnt apool/r/local/var /mnt/var
zmnt apool/r/local/nix /mnt/nix
zmnt apool/r/safe/state /mnt/state
zmnt apool/r/safe/state/home /mnt/state/home
zmnt apool/r/safe/state/home/vin /mnt/state/home/vin
zmnt apool/r/safe/state/home/vin/Downloads /mnt/state/home/vin/Downloads
mount $DISK-part1 /mnt/boot
```


## 2. install

``` sh
# This section should be run as the ISO user

git clone https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config

doas swapon $DISK-part2 # otherwise, nixos-install won't generate hardware config for this
nixos-generate-config --root /mnt --dir /tmp/nixos-config/hosts/scadrial

sed "s@networking.hostId = \".*\"@networking.hostId = \"$(head -c 8 /etc/machine-id)\"@" -i hosts/scadrial/modules/networking.nix
# copy old host key to /mnt/tmp/host/ed25519? or maybe it's /tmp/host/ed25519. why not both.
nix build /mnt/tmp/nixos-config#bootstrap --out-link /tmp/outsystem
nixos-install --system /tmp/outsystem --no-root-passwd --no-channel-copy

nixos-enter
  echo "nameserver 192.168.1.212" >> /etc/resolv.conf
  nix-daemon &>/dev/null &
  doas -u vin bash
    doas chown -R vin:users /tmp/nixos-config
    mv /tmp/nixos-config ~/flake
    doas nixos-rebuild switch --flake .
    # add new host key to .agenix.toml (assuming it exists yet... might
    #   need to be once new system is booted)

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
# syncthing setup
# copy authorized_keys
# copy chatterino stuff
# copy todo stuff
```


# Notes

## Backup win10 disk to fresh zvol

```sh
# /dev/sda is the Windows disk
# /dev/zd0 is the zvol's block device

# Need to copy the GPT in order to make zd0pX devices available
nix shell nixpkgs#gptfdisk
  sgdisk /dev/sda -R /dev/zd0
doas bash
  nix shell nixpkgs#pv
    pv /dev/sdaX >/dev/zd0pX
```
