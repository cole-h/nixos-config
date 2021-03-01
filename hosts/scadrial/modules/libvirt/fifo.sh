exec 2>>/tmp/win10.log
exec 1>&2

# Set FIFO scheduler
if pid=$(pidof qemu-system-x86_64); then
    chrt -f -p 1 "$pid"
    echo "$(date) Changing scheduling for qemu pid $pid"
    echo
fi
