# if the file exists, take ownership of it
[ -f /tmp/win10.log ] && chown root /tmp/win10.log

exec 2>>/tmp/win10.log
exec 1>&2

killall -e sway
echo "$(date) Tried to kill sway" >> /tmp/win10.log
sleep 1
ps aux | rg sway | rg -v rg && exit 1 # if sway is still running, everything breaks anyways

systemctl stop zrepl zrepl-replicate.timer
echo "$(date) Stopped snapshots while VM is live"

zpool export 14488990227566370050
echo "$(date) Exported bpool since it's connected via USB"

sync && echo 1 > /proc/sys/vm/drop_caches
echo "$(date) Freed memory to speed up VM POST"

cpupower frequency-set -g performance
echo "$(date) Changed CPU governors to performance"

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Unbound vtcon0"
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Unbound vtcon1"

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_09_00_0
echo "$(date) Unbound GPU"

virsh nodedev-detach pci_0000_09_00_1
echo "$(date) Unbound HDMI audio"

systemctl stop sonarr transmission jellyfin
echo "$(date) Stopped torrents and media"

virsh nodedev-detach pci_0000_0b_00_4
echo "$(date) Unbound front panel audio"

virsh nodedev-detach pci_0000_0b_00_3
echo "$(date) Unbound USB devices (M+KBD)"

virsh nodedev-detach pci_0000_06_00_3 # maybe problematic because of bluetooth?
virsh nodedev-detach pci_0000_06_00_1
echo "$(date) Unbound misc. USB devices"

# modprobe -r nouveau
# echo "$(date) Modprobe -r'd nouveau"

# Load VFIO Kernel Module
# modprobe vfio-pci
# echo "$(date) Modprobe'd vfio-pci"
# echo "$(date) Start"
