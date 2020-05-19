# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
echo "$(date) Modprobe -r'd vfio-pci, vfio_iommu_type1, and vfio" >> /tmp/win10.log

modprobe nouveau
echo "$(date) Modprobed nouveau" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_00_14_0
echo "$(date) Rebound USB devices (M+KBD)" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_00_1b_0
echo "$(date) Rebound snd_hda_intel (front panel audio)" >> /tmp/win10.log

virsh nodedev-reattach pci_0000_01_00_1
echo "$(date) Rebound snd_hda_intel (HDMI audio)" >> /tmp/win10.log

# Re-Bind GPU to Nvidia Driver
virsh nodedev-reattach pci_0000_01_00_0
echo "$(date) Rebound GPU" >> /tmp/win10.log

# Wait 1 second to avoid possible race condition
sleep 1

# Re-bind to virtual consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Rebound vtcon0" >> /tmp/win10.log
echo 1 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Rebound vtcon1" >> /tmp/win10.log

sleep 1
echo -e "$(date) End\n\n" >> /tmp/win10.log
