for f in livedata/umbra*.log; do
    awk -F, 'NR==1 {
        print "Time,CPU Percent,MEM Usage,IO Reads,_NProc"
        next
    }
    NR>1 {
        # $1=Time, $2=Total_CPU_Percent, $4=Current_Memory_GB
        mem_bytes = $4 * 1024 * 1024 * 1024
        print $1 "," $2 "," int(mem_bytes) ",0,0"
    }' "$f" > "${f%.log}.converted.log"
done