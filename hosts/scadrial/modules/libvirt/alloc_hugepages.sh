## Calculate number of hugepages to allocate from memory (in MB)
MEMORY=24576
HUGEPAGES="$((MEMORY/$(($(grep Hugepagesize /proc/meminfo | awk '{print $2}')/1024))))"

echo "$(date) Allocating hugepages..." >> /tmp/win10.log
echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)

TRIES=0
while [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ] && [ $TRIES -lt 1000 ]
do
    echo 1 > /proc/sys/vm/compact_memory ## defrag ram
    echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
    ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
    echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES"
    TRIES=$((TRIES + 1))
done

if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
then
    echo "$(date) Not able to allocate all hugepages. Reverting..." >> /tmp/win10.log
    echo 0 > /proc/sys/vm/nr_hugepages
    exit 1
fi

echo "$(date) Successfully allocated all hugepages" >> /tmp/win10.log
