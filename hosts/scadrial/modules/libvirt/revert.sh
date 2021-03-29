exec 2> >(systemd-cat -t win10)
exec 1>&2

virsh nodedev-reattach pci_0000_06_00_3
virsh nodedev-reattach pci_0000_06_00_1
echo ">>>> Rebound misc. USB devices"

virsh nodedev-reattach pci_0000_0b_00_3
echo ">>>> Rebound USB devices (M+KBD)"

virsh nodedev-reattach pci_0000_0b_00_4
echo ">>>> Rebound front panel audio"

systemctl restart sonarr transmission jellyfin
echo ">>>> Restarted torrents and media"

doas -u vin \
  env XDG_RUNTIME_DIR=/run/user/$(id -u vin) DBUS_SESSION_ADDRESS=unix:path=/run/user/$(id -u vin)/bus \
  systemctl restart --user pipewire.socket pipewire-pulse.socket
echo ">>>> Restarted user pulse"

virsh nodedev-reattach pci_0000_09_00_1
echo ">>>> Rebound HDMI audio"

virsh nodedev-reattach pci_0000_09_00_0
echo ">>>> Rebound GPU"

# Wait 1 second to avoid possible race condition
sleep 1

# Re-bind to virtual consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo ">>>> Rebound vtcon0"
echo 1 > /sys/class/vtconsole/vtcon1/bind
echo ">>>> Rebound vtcon1"

cpupower frequency-set -g schedutil
echo ">>>> Changed CPU governors to schedutil"

systemctl restart zrepl zrepl-replicate.timer
echo ">>>> Restarted snapshots"

echo ">>>> End"
echo ">>>>"
