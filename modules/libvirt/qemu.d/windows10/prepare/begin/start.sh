touch /tmp/win10.log
chmod 777 /tmp/win10.log

# Stop graphical session
stop_session() {
  while [[ $(systemctl show -p SubState --value display-manager.service) == "running" ]]
  do
    systemctl stop display-manager.service && echo "`date` Stopping display-manager" >> /tmp/win10.log
    sleep 1
  done

  while [[ $(pgrep -x sway) ]]
  do
    SWAYSOCK=/run/user/$(id -u vin)/sway-ipc.$(id -u vin).$(pgrep -x sway).sock swaymsg exit \
      && echo "`date` Stopping sway" >> /tmp/win10.log
    sleep 1
  done
}
stop_session

sync && echo 3 /proc/sys/vm/drop_caches
echo "`date` Freed memory to speed up VM POST" >> /tmp/win10.log

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo "`date` Unbound vtcon0" >> /tmp/win10.log
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo "`date` Unbound vtcon1" >> /tmp/win10.log

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
echo "`date` Unbound GPU" >> /tmp/win10.log

while pkill -9 jackdbus; do sleep 1; done
echo "`date` Killed jackdbus" >> /tmp/win10.log

virsh nodedev-detach pci_0000_01_00_1
echo "`date` Unbound snd_hda_intel (HDMI audio)" >> /tmp/win10.log

virsh nodedev-detach pci_0000_00_1b_0
echo "`date` Unbound snd_hda_intel (front panel audio)" >> /tmp/win10.log

virsh nodedev-detach pci_0000_00_14_0
echo "`date` Unbound USB devices (M+KBD)" >> /tmp/win10.log

modprobe -r nouveau
echo "`date` Modprobe -r'd nouveau" >> /tmp/win10.log

# Load VFIO Kernel Module
modprobe vfio-pci
echo "`date` Modprobe'd vfio-pci" >> /tmp/win10.log
echo "`date` Start" >> /tmp/win10.log
