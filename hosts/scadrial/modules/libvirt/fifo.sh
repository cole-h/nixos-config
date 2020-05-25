# Set FIFO scheduler
if pid=$(pidof qemu-system-x86_64); then
    chrt -f -p 1 "$pid"
    echo "$(date) Changing scheduling for qemu pid $pid" >> /tmp/win10.log
    echo >> /tmp/win10.log
fi
