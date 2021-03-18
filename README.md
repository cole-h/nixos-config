# dotfiles

### Hostnames

I'm a big fan of [Brandon Sanderson], so that's where all of my hostnames come
from (see [`names`](./names)). They were manually copy-pasted from throughout the
[Coppermind] wiki and are [planets, shards], general terms, worldhoppers, and
[locations] throughout his works. Any of these that had a space or apostrophe
were discarded.

[Brandon Sanderson]: https://www.brandonsanderson.com/
[Coppermind]: https://coppermind.net/wiki/Coppermind:Welcome
[planets, shards]: https://coppermind.net/wiki/Cosmere#Planets
[locations]: https://coppermind.net/wiki/Category:Locations

---

# Setup stuff

https://grahamc.com/blog/nixos-on-zfs

https://grahamc.com/blog/erase-your-darlings

https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

## 0. preparation
  - make iso with `nix build .#iso`
  - backup stateful stuff if reinstalling to same disk
    - FF profile
    - sonarr settings (watched shows, etc)
    - fish shell history
    - old host key for decrypting secrets, at least until you can get a new host key

## 1. partition
  - 2GiB /boot at the beginning
  - 32GiB swap partition at the beginning
  - rest "linux partition" (for ZFS) -- don't forget native encryption
    ("encryption=aes-256-gcm") and "compression=zstd"
    - apool/r
    - apool/r/local -- shouldn't be backed up
    - apool/r/local/root
    - apool/r/local/nix
    - apool/r/safe -- "safe" to back up
    - apool/r/safe/state/var
    - apool/r/safe/state/home
    - apool/r/safe/state/home/vin
    - apool/r/safe/state/home/vin/Downloads -- don't backup
    - apool/alloc -- 1G file to make sure we don't run out of space (can be freed to make fs stuff work again)

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
swapon $DISK-part2 # TODO: maybe it needs to be done later? idk

export POOL=apool
zpool create \
    -O mountpoint=none \
    # SSDs may or may not lie that it uses a 512B physical block size;
    # ashift of 12 (4k) shouldn't really hurt, according to various
    # people
    -o ashift=12 \
    # set altroot to /mnt so it'll automount, but to /mnt
    -R /mnt \
    $POOL $DISK-part3

zfs create \
    -o canmount=off \
    -o atime=off \
    # requires OpenZFS 2.0
    -o compression=zstd \
    # apparently gcm is faster than ccm
    -o encryption=aes-256-gcm -o keyformat=passphrase \
    # apparently useful with xattr=sa
    -o dnodesize=auto \
    -o xattr=sa \
    -o acltype=posixacl \
    # UTF-8 filenames only
    # -o normalization=formD \
    $POOL/r

# https://logs.nix.samueldr.com/nixos-chat/2021-03-15#1615840612-1615841027
# Add `options = ["zfsutil"];` to the really required datasets (/
# and /nix) in filesystems.nix
zfs create $POOL/r/local
zfs create $POOL/r/local/root -o mountpoint=/
zfs create $POOL/r/local/nix -o mountpoint=/nix
zfs create $POOL/r/safe
zfs create $POOL/r/safe/state -o mountpoint=/state
zfs create $POOL/r/safe/state/var -o mountpoint=/state/var
zfs create $POOL/r/safe/state/home -o mountpoint=/state/home
zfs create $POOL/r/safe/state/home/vin -o mountpoint=/state/home/vin
zfs create $POOL/r/safe/state/home/vin/Downloads -o mountpoint=/state/home/vin/Downloads
# zfs create -V 302G $POOL/r/win10

# copy tank key to /tmp/tank-key (add to usb?)
cp /tmp/tank-key /mnt/state
zpool import tank
zfs load-key -L file:///mnt/state/tank-key tank
zfs set keylocation=file:///state/tank-key tank

# Unmount the just-created datasets to prevent them from being detected
# when generating the hardware config.
zfs unmount -a

# keep space available in case it's ever needed
# to free up the space, `zfs set refreservation=none $POOL/alloc`
zfs create -o canmount=off -o refreservation=1G $POOL/alloc

# create snapshot of everything `@blank`
zfs snapshot -r $POOL@blank
# roll back with `zfs rollback -r <dataset>@blank`

# don't need to create /nix, /state, etc. because `zfs create` does
mkdir -p /mnt/boot /mnt/media /mnt/mnt

# mount stuff so it's detected by nixos-generate-config
mount -t zfs tank/system/media /mnt/media
mount $DISK-part1 /mnt/boot
```


## 2. install

``` sh
# This section should be run as the ISO user (typically nixos)

git clone https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config

# nixos-install won't generate hardware config for us
nixos-generate-config --root /mnt --dir /tmp/nixos-config/hosts/scadrial

# don't want to generate a config with our zfs-automounted datasets in
# it, so we mount AFTER we generate the hardware config
doas bash
  zfs mount $POOL/r/local/root
  zfs mount $POOL/r/local/nix
  zfs mount $POOL/r/safe/state
  zfs mount $POOL/r/safe/state/var
  zfs mount $POOL/r/safe/state/home
  zfs mount $POOL/r/safe/state/home/vin
  zfs mount $POOL/r/safe/state/home/vin/Downloads

sed "s@networking.hostId = \".*\"@networking.hostId = \"$(head -c8 /etc/machine-id)\"@" -i hosts/scadrial/modules/networking.nix
# copy old host key to /mnt/tmp/host/ed25519? or maybe it's /tmp/host/ed25519. why not both.
nix build /mnt/tmp/nixos-config#bootstrap --out-link /tmp/outsystem
nixos-install --system /tmp/outsystem --no-root-passwd --no-channel-copy

nixos-enter
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
  nix-daemon &>/dev/null &
  doas -u vin bash
    gpg --import # import secret key for user (used for pass and stuff)
    doas chown -R vin:users /tmp/nixos-config
    mv /tmp/nixos-config ~/flake
    # might need to get pinentry-curses and set pinentry-program in
    # ~/.gnupg/gpg-agent.conf
    doas nixos-rebuild switch --flake .
    # add new host key to .agenix.toml (assuming it exists yet... might
    #   need to be once new system is booted)

systemctl reboot
```


## 3. setup

``` sh
# This section should be run as the default user (vin, in this case)

doas mount -t zfs bpool/zrepl/sink/scadrial/apool/ROOT/user/home/vin /mnt -o ro
rsync -aP /mnt/.password-store/ ~/.password-store/
rsync -aP /mnt/.mozilla/ ~/.mozilla/
rsync -aP /mnt/workspace/ ~/workspace/
ln -s ~/.local/share/hydrus/db ~/workspace/vcs/hydrus/db
rsync -a /mnt/.cache/.j4_history ~/.cache/
rsync -aP --ignore-existing /mnt/.local/share/chatterino/ ~/.local/share/chatterino/
rsync -a /mnt/.local/share/zoxide/ ~/.local/share/zoxide/
rsync -a /mnt/.local/share/fish/fish_history ~/.local/share/fish/
# verify PCI addresses in windows10.xml and start.sh / revert.sh, then:
doas virsh define ..../windows10.xml

# update snapshot settings to use new dataset(s)
# copy sonarr settings (watched shows, etc) from backup
# fish_config for dracula colors
# syncthing setup
# copy weechat logs
# emacs all-the-icons-install-fonts to ~/.local/share/fonts
# copy authorized_keys
# copy chatterino stuff
# copy todo stuff
```
