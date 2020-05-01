# Set FIFO scheduler
if pid=$(pidof qemu-system-x86_64); then
    chrt -f -p 1 $pid
    echo -e "`date` Changing scheduling for qemu pid $pid\n\n" >> /tmp/win10.log
fi
