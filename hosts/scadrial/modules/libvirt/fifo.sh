exec 2> >(systemd-cat -t win10)
exec 1>&2

# Set FIFO scheduler
if pid=$(pidof qemu-system-x86_64); then
    chrt -f -p 1 "$pid"
    echo ">>>> Changing scheduling for qemu pid $pid"
    echo ">>>>"
fi
