# if the file exists, take ownership of it
[ -f /tmp/win10.log ] && chown root /tmp/win10.log

killall -e sway
echo "$(date) Tried to kill sway" >> /tmp/win10.log
sleep 1
ps aux | rg sway | rg -v rg && exit 1 # if sway is still running, everything breaks anyways

zpool export bpool
echo "$(date) Exported bpool since it's connected via USB" >> /tmp/win10.log

sync && echo 1 > /proc/sys/vm/drop_caches
echo "$(date) Freed memory to speed up VM POST" >> /tmp/win10.log

cpupower frequency-set -g performance
echo "$(date) Changed CPU governors to performance" >> /tmp/win10.log

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Unbound vtcon0" >> /tmp/win10.log
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Unbound vtcon1" >> /tmp/win10.log

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_09_00_0
echo "$(date) Unbound GPU" >> /tmp/win10.log

virsh nodedev-detach pci_0000_09_00_1
echo "$(date) Unbound HDMI audio" >> /tmp/win10.log

systemctl stop znapzend
echo "$(date) Stopped snapshots while VM is live" >> /tmp/win10.log

systemctl stop sonarr transmission jellyfin
echo "$(date) Stopped torrents and media" >> /tmp/win10.log

virsh nodedev-detach pci_0000_0b_00_4
echo "$(date) Unbound front panel audio" >> /tmp/win10.log

virsh nodedev-detach pci_0000_0b_00_3
echo "$(date) Unbound USB devices (M+KBD)" >> /tmp/win10.log

virsh nodedev-detach pci_0000_06_00_3 # maybe problematic because of bluetooth?
virsh nodedev-detach pci_0000_06_00_1
echo "$(date) Unbound misc. USB devices" >> /tmp/win10.log

modprobe -r nouveau
echo "$(date) Modprobe -r'd nouveau" >> /tmp/win10.log

# Load VFIO Kernel Module
modprobe vfio-pci
echo "$(date) Modprobe'd vfio-pci" >> /tmp/win10.log
echo "$(date) Start" >> /tmp/win10.log
