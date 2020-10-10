# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
echo "$(date) Modprobe -r'd vfio-pci, vfio_iommu_type1, and vfio" >> /tmp/win10.log

modprobe nouveau
echo "$(date) Modprobed nouveau" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_0a_00_3
echo "$(date) Rebound USB devices (M+KBD)" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_0a_00_4
echo "$(date) Rebound front panel audio" >> /tmp/win10.log

systemctl restart znapzend
echo "$(date) Restarted snapshots" >> /tmp/win10.log

systemctl restart sonarr transmission
echo "$(date) Restarted torrents" >> /tmp/win10.log

doas -u vin systemctl restart --user pulseaudio.socket
echo "$(date) Restarted user pulse" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_08_00_1
echo "$(date) Rebound HDMI audio" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_08_00_0
echo "$(date) Rebound GPU" >> /tmp/win10.log

# Wait 1 second to avoid possible race condition
sleep 1

# Re-bind to virtual consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Rebound vtcon0" >> /tmp/win10.log
echo 1 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Rebound vtcon1" >> /tmp/win10.log

cpupower frequency-set -g schedutil
echo "$(date) Changed CPU governors to schedutil" >> /tmp/win10.log

sleep 1
echo "$(date) End" >> /tmp/win10.log
echo >> /tmp/win10.log
