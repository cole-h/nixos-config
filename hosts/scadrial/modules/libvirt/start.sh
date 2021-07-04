exec 2> >(systemd-cat -t win10)
exec 1>&2

killall -e sway 2>/dev/null
echo ">>>> Tried to kill sway" >> /tmp/win10.log
ps aux | rg sway | rg -v rg && exit 1 # if sway is still running, everything breaks anyways

systemctl stop zrepl.service zrepl-replicate.timer zrepl-replicate.service
echo ">>>> Stopped snapshots while VM is live"
ps aux | rg zrepl | rg -v rg && exit 1 # if zrepl is still running, everything breaks anyways

zpool export bpool
zpool list bpool 2>/dev/null && exit 1 # if bpool is still there, detaching it can corrupt data
echo ">>>> Exported bpool since it's connected via USB"

sleep 1
echo ">>>> Sleeping before we continue"

sync && echo 1 > /proc/sys/vm/drop_caches
echo ">>>> Freed memory to speed up VM POST"

cpupower frequency-set -g performance
echo ">>>> Changed CPU governors to performance"

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo ">>>> Unbound vtcon0"
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo ">>>> Unbound vtcon1"

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_09_00_0
echo ">>>> Unbound GPU"

virsh nodedev-detach pci_0000_09_00_1
echo ">>>> Unbound HDMI audio"

systemctl stop sonarr transmission jellyfin
echo ">>>> Stopped torrents and media"

virsh nodedev-detach pci_0000_0b_00_4
echo ">>>> Unbound front panel audio"

virsh nodedev-detach pci_0000_0b_00_3
echo ">>>> Unbound USB devices (M+KBD)"

virsh nodedev-detach pci_0000_06_00_3 # maybe problematic because of bluetooth?
virsh nodedev-detach pci_0000_06_00_1
echo ">>>> Unbound misc. USB devices"
