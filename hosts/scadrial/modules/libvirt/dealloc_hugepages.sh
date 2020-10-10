echo 0 > /proc/sys/vm/nr_hugepages
echo "$(date) Deallocated all hugepages" >> /tmp/win10.log
