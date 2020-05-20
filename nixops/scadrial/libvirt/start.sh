sync && echo 3 /proc/sys/vm/drop_caches
echo "$(date) Freed memory to speed up VM POST" >> /tmp/win10.log

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo "$(date) Unbound vtcon0" >> /tmp/win10.log
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo "$(date) Unbound vtcon1" >> /tmp/win10.log

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
echo "$(date) Unbound GPU" >> /tmp/win10.log

while pkill -9 jackdbus; do sleep 1; done
echo "$(date) Killed jackdbus" >> /tmp/win10.log

virsh nodedev-detach pci_0000_01_00_1
echo "$(date) Unbound snd_hda_intel (HDMI audio)" >> /tmp/win10.log

virsh nodedev-detach pci_0000_00_1b_0
echo "$(date) Unbound snd_hda_intel (front panel audio)" >> /tmp/win10.log

virsh nodedev-detach pci_0000_00_14_0
echo "$(date) Unbound USB devices (M+KBD)" >> /tmp/win10.log

modprobe -r nouveau
echo "$(date) Modprobe -r'd nouveau" >> /tmp/win10.log

# Load VFIO Kernel Module
modprobe vfio-pci
echo "$(date) Modprobe'd vfio-pci" >> /tmp/win10.log
echo "$(date) Start" >> /tmp/win10.log
