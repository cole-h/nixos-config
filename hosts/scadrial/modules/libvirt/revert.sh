exec 2>>/tmp/win10.log
exec 1>&2

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
echo "$(date) Modprobe -r'd vfio-pci, vfio_iommu_type1, and vfio"

modprobe nouveau
echo "$(date) Modprobed nouveau"

virsh nodedev-reattach pci_0000_06_00_3
virsh nodedev-reattach pci_0000_06_00_1
echo "$(date) Rebound misc. USB devices"

virsh nodedev-reattach pci_0000_0b_00_3
echo "$(date) Rebound USB devices (M+KBD)"

virsh nodedev-reattach pci_0000_0b_00_4
echo "$(date) Rebound front panel audio"

systemctl restart sonarr transmission jellyfin
echo "$(date) Restarted torrents and media"

doas -u vin systemctl restart --user pulseaudio.socket
echo "$(date) Restarted user pulse"

virsh nodedev-reattach pci_0000_09_00_1
echo "$(date) Rebound HDMI audio"

virsh nodedev-reattach pci_0000_09_00_0
echo "$(date) Rebound GPU"

# Wait 1 second to avoid possible race condition
sleep 1

# Re-bind to virtual consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Rebound vtcon0"
echo 1 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Rebound vtcon1"

cpupower frequency-set -g schedutil
echo "$(date) Changed CPU governors to schedutil"

zpool import bpool
echo "$(date) Imported bpool"

systemctl restart zrepl zrepl-replicate.timer
echo "$(date) Restarted snapshots"

echo "$(date) End"
echo
